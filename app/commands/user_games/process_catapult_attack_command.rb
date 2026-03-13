module UserGames
  class ProcessCatapultAttackCommand < BaseCommand
    # --- Score-ratio run/victory-point tiers for catapult battles ---
    SCORE_TIERS = [
      { ratio: 16, run: 0.40, victory: 0.10 },
      { ratio:  8, run: 0.20, victory: 0.25 },
      { ratio:  4, run: 0.10, victory: 0.50 },
      { ratio:  2, run: 0.05, victory: 0.75 },
    ].freeze

    # --- Repeated-attack penalty tiers (same structure as army attack) ---
    ATTACK_PENALTY_TIERS = [
      { range: (3..4),              victory_mult: 0.80, attack_mult: 0.92 },
      { range: (5..7),              victory_mult: 0.65, attack_mult: 0.84 },
      { range: (8..9),              victory_mult: 0.50, attack_mult: 0.76 },
      { range: (10..11),            victory_mult: 0.35, attack_mult: 0.68 },
      { range: (12..14),            victory_mult: 0.20, attack_mult: 0.60 },
      { range: (15..Float::INFINITY), victory_mult: 0.01, attack_mult: 0.25 },
    ].freeze

    # Battle point randomization: ±10% variance
    BATTLE_VARIANCE = 0.1

    # --- Catapult casualty divisors ---
    # When attacker is stronger: fewer catapult casualties per battle-point
    CATAPULT_CASUALTY_DIVISOR_STRONG  = 650.0
    CATAPULT_ATTACKER_DIVISOR_STRONG  = 400.0
    # When defender is equally strong or stronger
    CATAPULT_CASUALTY_DIVISOR_WEAK    = 400.0
    CATAPULT_ATTACKER_DIVISOR_WEAK    = 650.0

    # Towers defend against catapults: this ratio determines how many defending towers
    # destroy attacking catapults, and how many towers catapults can destroy
    TOWER_CATAPULT_KILL_RATIO = 10.0

    # Catapults kill this many people per catapult when targeting population
    POPULATION_KILL_FACTOR = 12

    # Fraction of catapult attack-points applied to building destruction
    BUILDINGS_ATTACK_FACTOR = 0.5

    # Attack history weights (same as army attack)
    ATTACK_HISTORY_LOST_WEIGHT  = 3.0
    ATTACK_HISTORY_OTHER_WEIGHT = 5.0

    attr_reader :user_game, :data, :attack_queue, :defender, :defender_soldiers, :game, :has_attacks, :attack_catapults,
      :defense_catapults, :attack_message, :victory_points, :attack_points, :defense_points

    def initialize(user_game:, data:, attack_queue:)
      @user_game = user_game
      @data = data
      @attack_queue = attack_queue
      @defender = attack_queue.to_user_game
      @defender_soldiers = PrepareSoldiersDataCommand.new(
        game: defender.game, civilization: defender.civilization
      ).call.with_indifferent_access
      @game = user_game.game

      setup_battle_parameters

      super()
    end

    def call
      return { success: false, message: 'Defender no longer exists' } unless defender&.persisted?

      process_catapult_attack
    end

    private

    def process_catapult_attack
      calculate_attack_penalties
      apply_weak_opponent_penalties
      calculate_battle_points
      determine_casualties
      determine_winner
      execute_attack_effects if @attacker_wins
      update_databases
      attack_log = record_battle_news

      {
        success: true,
        message: @attack_message,
        attacker_wins: @attacker_wins,
        stolen_resources: @stolen_resources,
        attack_log: attack_log
      }
    end

    def calculate_attack_penalties
      since_date = 24.hours.ago

      my_attacks = AttackLog.where(
        attacker_id: user_game.id,
        defender_id: defender.id,
        created_at: since_date..,
        attack_type: AttackQueue::CATAPULT_TYPES,
      )

      my_won_attacks = my_attacks.select { _1.attacker_wins }.length
      my_lost_attacks = my_attacks.select { !_1.attacker_wins }.length

      other_won_attacks = AttackLog.where.not(attacker_id: user_game.id)
                                   .where(
                                     defender_id: defender.id,
                                     created_at: since_date..,
                                     attack_type: AttackQueue::CATAPULT_TYPES,
                                     attacker_wins: true
                                   ).count

      # Weighted sum: own wins count fully, own losses at 1/3, others' wins at 1/5
      @has_attacks = (my_won_attacks + my_lost_attacks / ATTACK_HISTORY_LOST_WEIGHT + other_won_attacks / ATTACK_HISTORY_OTHER_WEIGHT).round
    end

    def setup_battle_parameters
      @run_percent = 0
      @victory_points = 1

      return if defender.blank?

      tier = SCORE_TIERS.find { |t| user_game.score > defender.score * t[:ratio] }
      if tier
        @run_percent = tier[:run]
        @victory_points = tier[:victory]
      end

      @attack_message = [
        "--------- Catapult Battle #{user_game.user.name} (#{user_game.id}) vs. #{defender.user.name} " \
          "(#{defender.id}) #{Time.current.strftime('%Y-%m-%d %H:%M')} ---------"
      ]
    end

    def apply_weak_opponent_penalties
      @attack_catapults = attack_queue.catapult_soldiers
      @defense_catapults = defender.catapult_soldiers

      if @run_percent > 0
        run_catapults = (attack_catapults * @run_percent).round
        @attack_message << "#{user_game.user.name} attacked much weaker enemy. #{run_catapults} catapults revolt and go away."
        @attack_catapults -= run_catapults
      end
    end

    def calculate_battle_points
      catapult_attack_points = attack_catapults * data[:soldiers][:catapult][:settings][:attack_points]
      @attack_points = (catapult_attack_points * (1 + user_game.catapults_strength_researches / 100.0)).round

      apply_attack_penalties

      defense_base = defense_catapults * defender_soldiers[:catapult][:settings][:defense_points]
      @defense_points = (defense_base * (1 + defender.catapults_strength_researches / 100.0)).round

      randomize_battle_points
    end

    def apply_attack_penalties
      tier = ATTACK_PENALTY_TIERS.find { |t| t[:range].include?(has_attacks) }
      return unless tier

      @victory_points *= tier[:victory_mult]
      @attack_points = (attack_points * tier[:attack_mult]).round

      if has_attacks >= 15
        @attack_message << "#{defender.user.name} was attacked too many times in the past 24 hours. <br>#{user_game.user.name} army is weakened!!!!"
      end
    end

    def randomize_battle_points
      # Apply ±BATTLE_VARIANCE random swing to both sides
      a_start = attack_points - (attack_points * BATTLE_VARIANCE).round
      a_end = attack_points + (attack_points * BATTLE_VARIANCE).round
      d_start = defense_points - (defense_points * BATTLE_VARIANCE).round
      d_end = defense_points + (defense_points * BATTLE_VARIANCE).round

      @attack_points = rand(a_start..a_end)
      @defense_points = rand(d_start..d_end)
    end

    def determine_casualties
      # When attacker is stronger: fewer kills per point (strong side); more kills when matched (weak side)
      if defender.score < user_game.score
        defender_casualties = ((attack_points / CATAPULT_CASUALTY_DIVISOR_STRONG) * victory_points).round
        attacker_casualties = (defense_points / CATAPULT_ATTACKER_DIVISOR_STRONG).round
      else
        defender_casualties = ((attack_points / CATAPULT_CASUALTY_DIVISOR_WEAK) * victory_points).round
        attacker_casualties = (defense_points / CATAPULT_ATTACKER_DIVISOR_WEAK).round
      end

      @defender_casualties = [defender_casualties, defense_catapults].min
      @defense_catapults = [defense_catapults - @defender_casualties, 0].max

      @attacker_casualties = [attacker_casualties, @attack_catapults].min
      @attack_catapults = [attack_catapults - @attacker_casualties, 0].max

      @attack_message << "#{user_game.user.name} destroyed #{@defender_casualties} catapults"
      @attack_message << "#{defender.user.name} destroyed #{@attacker_casualties} catapults"
    end

    def determine_winner
      @attacker_wins = attack_points > defense_points

      if @attacker_wins
        @attack_message << "#{user_game.user.name} won the war!"
      else
        @attack_message << "#{defender.user.name} won the war!"
      end
    end

    def execute_attack_effects
      case attack_queue.attack_type
      when 'catapult_army_and_towers'
        process_army_and_towers
      when 'catapult_population'
        process_population
      when 'catapult_buildings'
        process_buildings
      end
    end

    def process_army_and_towers
      attack_points = (attack_catapults * victory_points).round

      # Handle towers: towers kill catapults at 1 per TOWER_CATAPULT_KILL_RATIO towers;
      # surviving catapults raze towers at 1 per TOWER_CATAPULT_KILL_RATIO attack-points
      if defender.tower > 0
        cats_killed = (defender.tower / TOWER_CATAPULT_KILL_RATIO).round
        cats_killed = [cats_killed, attack_catapults].min
        @attack_catapults -= cats_killed
        @attack_message << "#{cats_killed} attacking catapults were annihilated by defending towers"

        d_tower = (attack_points / TOWER_CATAPULT_KILL_RATIO).round
        d_tower = [d_tower, defender.tower].min
        defender.tower -= d_tower
        @attack_message << "and #{d_tower} towers were razed by attacking catapults."
      end

      # Handle an army
      attack_points = (attack_catapults * victory_points).round

      defender_army = {}
      UserGame::SOLDIERS.keys.each do |soldier_key|
        next if defender.send("#{soldier_key}_soldiers").zero?

        defender_army[soldier_key] = defender.send("#{soldier_key}_soldiers")
      end

      if attack_points > 0 && defender_army.present?
        total_army = defender_army.values.sum
        casualties = {}

        defender_army.each do |soldier_key, count|
          casualty = ((count.to_f / total_army) * attack_points).round
          casualties[soldier_key] = [casualty, count].min
        end

        casualties.each do |type, count|
          defender.send("#{type}_soldiers=", defender.send("#{type}_soldiers") - count)
        end
        defender.save!

        @attack_message << "#{user_game.user.name} catapulted #{total_army} army units"
      else
        @attack_message << 'No army killed.'
      end
    end

    def process_population
      # Each catapult kills POPULATION_KILL_FACTOR people scaled by victory points
      attack_points = (attack_catapults * POPULATION_KILL_FACTOR * victory_points).round

      if attack_points > 0 && defender.people > 0
        kill_people = [attack_points, defender.people].min
        defender.people = [defender.people - kill_people, UserGame::MIN_PEOPLE].max
        defender.save!

        @attack_message << "#{kill_people} people were killed by #{user_game.user.name} catapults."
      else
        @attack_message << 'But failed to kill any people'
      end
    end

    def process_buildings
      # Scale down catapult attack power for building destruction
      attack_points = (attack_catapults * victory_points * BUILDINGS_ATTACK_FACTOR).round

      defender_buildings = {}
      UserGame::BUILDINGS.each do |building|
        defender_buildings[building] = defender.send(building)
      end

      if attack_points > 0 && defender_buildings.present?
        total_buildings = defender_buildings.values.sum
        casualties = {}

        defender_buildings.each do |building, count|
          casualty = ((count.to_f / total_buildings) * attack_points).round
          casualty = [casualty, count].min
          casualties[building] = casualty
        end

        UpdateCountersCommand.new(object: defender, changes: casualties.transform_values { |v| -v }).execute
        defender.save!

        @attack_message << "#{user_game.user.name} catapulted #{total_buildings} buildings"
      else
        @attack_message << 'But failed to destroy any building.'
      end
    end

    def update_databases
      remaining_attack_catapults = attack_catapults - @attacker_casualties
      attack_queue.update!(catapult_soldiers: remaining_attack_catapults)

      remaining_defense_catapults = defense_catapults - @defender_casualties
      defender.update!(catapult_soldiers: remaining_defense_catapults)

      UserGames::UpdateScoreCommand.new(user_game: defender).call

      @attack_message = @attack_message.join("\n")
    end

    def record_battle_news
      AttackLog.create!(
        attacker_id: user_game.id,
        defender_id: defender.id,
        attack_type: attack_queue.attack_type,
        attacker_wins: @attacker_wins,
        casualties: { catapult: { attacker: @attacker_casualties, defender: @defender_casualties } },
        attack_message: @attack_message,
      )
    end
  end
end
