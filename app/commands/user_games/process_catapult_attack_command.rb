module UserGames
  class ProcessCatapultAttackCommand < BaseCommand
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
        attack_type: attack_queue.attack_type,
      )

      my_won_attacks = my_attacks.select { _1.attacker_wins }.length
      my_lost_attacks = my_attacks.select { !_1.attacker_wins }.length

      other_won_attacks = AttackLog.where.not(attacker_id: user_game.id)
                                   .where(
                                     defender_id: defender.id,
                                     created_at: since_date..,
                                     attack_type: attack_queue.attack_type,
                                     attacker_wins: true
                                   ).count

      @has_attacks = (my_won_attacks + my_lost_attacks / 3.0 + other_won_attacks / 5.0).round
    end

    def setup_battle_parameters
      @run_percent = 0
      @victory_points = 1

      if user_game.score > defender.score * 16
        @run_percent = 0.4
        @victory_points = 0.1
      elsif user_game.score > defender.score * 8
        @run_percent = 0.2
        @victory_points = 0.25
      elsif user_game.score > defender.score * 4
        @run_percent = 0.1
        @victory_points = 0.5
      elsif user_game.score > defender.score * 2
        @run_percent = 0.05
        @victory_points = 0.75
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
      case has_attacks
      when 3..4
        @victory_points *= 0.80
        @attack_points = (attack_points * 0.92).round
      when 5..7
        @victory_points *= 0.65
        @attack_points = (attack_points * 0.84).round
      when 8..9
        @victory_points *= 0.50
        @attack_points = (attack_points * 0.76).round
      when 10..11
        @victory_points *= 0.35
        @attack_points = (attack_points * 0.68).round
      when 12..14
        @victory_points *= 0.20
        @attack_points = (attack_points * 0.60).round
      when 15..Float::INFINITY
        @victory_points *= 0.01
        @attack_points = (attack_points * 0.25).round
        @attack_message += "#{defender.user.name} was attacked too many times in the past 24 hours. <br>#{user_game.user.name} army is weakened!!!!"
      end
    end

    def randomize_battle_points
      a_start = attack_points - (attack_points * 0.1).round
      a_end = attack_points + (attack_points * 0.1).round
      d_start = defense_points - (defense_points * 0.1).round
      d_end = defense_points + (defense_points * 0.1).round

      @attack_points = rand(a_start..a_end)
      @defense_points = rand(d_start..d_end)
    end

    def determine_casualties
      if defender.score < user_game.score
        defender_casualties = ((attack_points / 650.0) * victory_points).round
        attacker_casualties = (defense_points / 400.0).round
      else
        defender_casualties = ((attack_points / 400.0) * victory_points).round
        attacker_casualties = (defense_points / 650.0).round
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

      # Handle towers
      if defender.tower > 0
        cats_killed = (defender.tower / 10.0).round
        cats_killed = [cats_killed, attack_catapults].min
        @attack_catapults -= cats_killed
        @attack_message << "#{cats_killed} attacking catapults were annihilated by defending towers"

        d_tower = (attack_points / 10.0).round
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
      attack_points = (attack_catapults * 12 * victory_points).round

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
      attack_points = (attack_catapults * victory_points * 0.5).round

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
