module UserGames
  class ProcessThiefAttackCommand < BaseCommand
    attr_reader :user_game, :data, :attack_queue, :defender, :defender_soldiers, :game, :has_attacks, :attack_thieves,
      :defense_thieves, :attack_message, :victory_points, :attack_points, :defense_points

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

      process_attack
    end

    private

    def process_attack
      calculate_attack_history
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

    def calculate_attack_history
      since_date = 24.hours.ago

      my_attacks = AttackLog.where(
        attacker_id: user_game.id,
        defender_id: defender.id,
        created_at: since_date..,
        attack_type: AttackQueue::THIEF_TYPES,
      )

      my_won_attacks = my_attacks.select { _1.attacker_wins }.length
      my_lost_attacks = my_attacks.select { !_1.attacker_wins }.length

      other_won_attacks = AttackLog.where.not(attacker_id: user_game.id)
                                   .where(
                                     defender_id: defender.id,
                                     created_at: since_date..,
                                     attack_type: AttackQueue::THIEF_TYPES,
                                     attacker_wins: true
                                   ).count

      @has_attacks = (my_won_attacks + my_lost_attacks / 3.0 + other_won_attacks / 5.0).round
    end

    def setup_battle_parameters
      @stolen_resources = {}
      @attack_thieves = attack_queue.thieve_soldiers
      @defense_thieves = defender.thieve_soldiers
      @attack_message = [
        "--------- Thieves Battle #{user_game.user.name} (#{user_game.id}) vs. #{defender.user.name} " \
          "(#{defender.id}) #{Time.current.strftime('%Y-%m-%d %H:%M')} ---------"
      ]
      @victory_points = 1.0
    end

    def calculate_battle_points
      thief_attack_points = attack_thieves * data[:soldiers][:thieve][:settings][:attack_points]
      @attack_points = (thief_attack_points * (1 + user_game.thieves_strength_researches / 100.0)).round

      apply_attack_penalties

      defense_base = defense_thieves * defender_soldiers[:thieve][:settings][:defense_points]
      @defense_points = (defense_base * (1 + defender.thieves_strength_researches / 100.0)).round

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
        @attack_message << "#{defender.user.name} was attacked too many times in the past 24 hours. #{user_game.user.name} army is weakened!!!!"
      end
    end

    def randomize_battle_points
      attack_variance = (attack_points * 0.1).round
      defense_variance = (defense_points * 0.1).round

      @attack_points = rand((attack_points - attack_variance)..(attack_points + attack_variance))
      @defense_points = rand((defense_points - defense_variance)..(defense_points + defense_variance))
    end

    def determine_casualties
      if defender.score < user_game.score
        defender_casualties = ((attack_points / 800.0) * victory_points).round
        attacker_casualties = (defense_points / 500.0).round
      else
        defender_casualties = ((attack_points / 500.0) * victory_points).round
        attacker_casualties = (defense_points / 800.0).round
      end
      @defender_casualties = [defender_casualties, defense_thieves].min
      @attacker_casualties = [attacker_casualties, attack_thieves].min

      @attack_message << "#{user_game.user.name} thieves kill #{@defender_casualties} thieves. "
      @attack_message << "#{defender.user.name} thieves kill #{@attacker_casualties} thieves. "
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
      when 'thief_steal_army_information'
        steal_army_information
      when 'thief_steal_building_information'
        steal_building_information
      when 'thief_steal_research_information'
        steal_research_information
      when 'thief_steal_goods'
        steal_goods
      when 'thief_poison_water'
        poison_water
      when 'thief_set_fire'
        burn_buildings
      end
    end

    def steal_army_information
      @attack_message << "#{user_game.user.name} learns the following information: "
      @attack_message << "People: #{defender.people}, "

      UserGame::SOLDIERS.keys.each do |soldier_key|
        @attack_message << "#{defender_soldiers[soldier_key][:name]}: #{defender.send("#{soldier_key}_soldiers").to_i }, "
      end

      @attack_message << "Towers: #{defender.tower}"
    end

    def steal_building_information
      @attack_message << "#{user_game.user.name} learns building information: "
      building_info = []
      building_info << "Houses: #{defender.house}"
      building_info << "Farms: #{defender.farm}"
      building_info << "Wood Cutters: #{defender.wood_cutter}"
      building_info << "Gold Mines: #{defender.gold_mine}"
      building_info << "Iron Mines: #{defender.iron_mine}"
      building_info << "Tool Makers: #{defender.tool_maker}"
      building_info << "Weapon Smiths: #{defender.weaponsmith}"
      building_info << "Markets: #{defender.market}"
      building_info << "Warehouses: #{defender.warehouse}"
      building_info << "Stables: #{defender.stable}"
      building_info << "Wineries: #{defender.winery}"
      @attack_message << building_info.join(', ')
    end

    def steal_research_information
      @attack_message << "#{user_game.user.name} learns research information: "
      research_info = []
      research_info << "Attack Points: #{defender.attack_points_researches}"
      research_info << "Defense Points: #{defender.defense_points_researches}"
      research_info << "Thieves Strength: #{defender.thieves_strength_researches}"
      research_info << "Military Losses: #{defender.military_losses_researches}"
      research_info << "Food Production: #{defender.food_production_researches}"
      research_info << "Mine Production: #{defender.mine_production_researches}"
      @attack_message << research_info.join(', ')
    end

    def steal_goods
      # get between 2.5 and 5 percents of what another player has
      percentage = rand(250..500) / 10000.0
      percentage = percentage * victory_points

      %i[gold iron wood food tools maces swords bows horses wine].each do |resource|
        stolen_amount = (defender.send(resource) * percentage).round
        next if stolen_amount.zero?

        @stolen_resources[resource] = stolen_amount
      end

      UpdateCountersCommand.new(object: defender, changes: @stolen_resources.transform_values { |v| -v }).execute

      @attack_message << "#{user_game.user.name} steals #{@stolen_resources.map { |k, v| "#{v} #{k}" }.join(', ')}"
    end

    def poison_water
      # kill between 2 and 4 percents of army and people
      percentage = rand(200..400) / 10000.0
      percentage = percentage * victory_points

      casualties = 0
      UserGame::SOLDIERS.keys.each do |soldier_key|
        killed = (defender.send("#{soldier_key}_soldiers") * percentage).round
        next if killed.zero?

        casualties += killed
        defender.send("#{soldier_key}_soldiers=", defender.send("#{soldier_key}_soldiers") - killed)
      end

      killed_people = (defender.people * percentage).round
      defender.send('people=', [defender.people - killed_people, UserGame::MIN_PEOPLE].max)
      defender.save!
      @attack_message << "#{user_game.user.name} poisoned #{casualties} army units and #{killed_people} people"
    end

    def burn_buildings
      # burn between 2 and 4 percents of buildings
      percentage = rand(200..400) / 10000.0
      percentage = percentage * victory_points

      destroyed = {}
      UserGame::BUILDINGS.each do |building|
        destroyed_count = (defender.send(building) * percentage).round
        destroyed[building] = destroyed_count
      end

      UpdateCountersCommand.new(object: defender, changes: destroyed.transform_values { |v| -v }).execute

      total_destroyed = destroyed.values.sum
      @attack_message << "Fire destroyed #{total_destroyed} buildings: #{destroyed.select { |_, v| v > 0 }.map { |k, v| "#{v} #{k.humanize}" }.join(', ')}"
    end

    def update_databases
      remaining_attack_thieves = attack_thieves - @attacker_casualties
      attack_queue.update!(thieve_soldiers: remaining_attack_thieves)

      remaining_defense_thieves = defense_thieves - @defender_casualties
      defender.update!(thieve_soldiers: remaining_defense_thieves)

      @attack_message = @attack_message.join("\n")
    end

    def record_battle_news
      AttackLog.create!(
        attacker_id: user_game.id,
        defender_id: defender.id,
        attack_type: attack_queue.attack_type,
        attacker_wins: @attacker_wins,
        casualties: { thieve: { attacker: @attacker_casualties, defender: @defender_casualties } },
        attack_message: @attack_message,
      )
    end
  end
end
