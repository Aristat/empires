module UserGames
  class ProcessArmyAttackCommand < BaseCommand
    attr_reader :user_game, :data, :attack_queue, :defender, :defender_soldiers, :game, :has_attacks,
                :attack_points, :defense_points

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

      process_army_attack
    end

    private

    def process_army_attack
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
        attack_log: attack_log
      }
    end

    def calculate_attack_penalties
      since_date = 24.hours.ago

      my_attacks = AttackLog.where(
        attacker_id: user_game.id,
        defender_id: defender.id,
        created_at: since_date..,
        attack_type: AttackQueue::ARMY_TYPES,
      )

      my_won_attacks = my_attacks.select { _1.attacker_wins }.length
      my_lost_attacks = my_attacks.select { !_1.attacker_wins }.length

      other_won_attacks = AttackLog.where.not(attacker_id: user_game.id)
                                   .where(
                                     defender_id: defender.id,
                                     created_at: since_date..,
                                     attack_type: AttackQueue::ARMY_TYPES,
                                     attacker_wins: true
                                   ).count

      @has_attacks = (my_won_attacks + my_lost_attacks / 3.0 + other_won_attacks / 5.0).round
    end

    def setup_battle_parameters
      @run_percent = 0
      @victory_points = 1

      return if defender.blank?

      if user_game.score > defender.score * 10
        @run_percent = 0.80
        @victory_points = 0.01
      elsif user_game.score > defender.score * 8
        @run_percent = 0.70
        @victory_points = 0.05
      elsif user_game.score > defender.score * 6
        @run_percent = 0.60
        @victory_points = 0.10
      elsif user_game.score > defender.score * 5
        @run_percent = 0.50
        @victory_points = 0.20
      elsif user_game.score > defender.score * 4
        @run_percent = 0.40
        @victory_points = 0.30
      elsif user_game.score > defender.score * 3
        @run_percent = 0.30
        @victory_points = 0.40
      elsif user_game.score > defender.score * 2
        @run_percent = 0.20
        @victory_points = 0.50
      end

      @attack_message = [
        "--------- Battle #{user_game.user.name} (#{user_game.id}) vs. #{defender.user.name} " \
          "(#{defender.id}) #{Time.current.strftime('%Y-%m-%d %H:%M')} ---------"
      ]
    end

    def apply_weak_opponent_penalties
      @attack_unique_unit = attack_queue.unique_unit_soldiers
      @defense_unique_unit = defender.unique_unit_soldiers
      @attack_archer = attack_queue.archer_soldiers
      @defense_archer = defender.archer_soldiers
      @attack_swordsman = attack_queue.swordsman_soldiers
      @defense_swordsman = defender.swordsman_soldiers
      @attack_horseman = attack_queue.horseman_soldiers
      @defense_horseman = defender.horseman_soldiers
      @attack_macemen = attack_queue.macemen_soldiers
      @defense_macemen = defender.macemen_soldiers
      @attack_trained_peasant = attack_queue.trained_peasant_soldiers
      @defense_trained_peasant = defender.trained_peasant_soldiers
      @defense_tower = defender.tower

      if @run_percent > 0
        run_unique_unit = (@attack_unique_unit * @run_percent).round
        run_swordsman = (@attack_swordsman * @run_percent).round
        run_archer = (@attack_archer * @run_percent).round
        run_horseman = (@attack_horseman * @run_percent).round
        run_macemen = (@attack_macemen * @run_percent).round
        run_trained_peasant = (@attack_trained_peasant * @run_percent).round

        @attack_message << "#{user_game.user.name} attacked much weaker enemy. #{run_unique_unit} #{data[:soldiers][:unique_unit][:name]}, " \
          "#{run_trained_peasant} peasants, #{run_macemen} macemen, #{run_swordsman} swordsman, #{run_archer} archers " \
          "and #{run_horseman} horseman revolt and go away."

        @attack_unique_unit -= run_unique_unit
        @attack_swordsman -= run_swordsman
        @attack_archer -= run_archer
        @attack_horseman -= run_horseman
        @attack_macemen -= run_macemen
        @attack_trained_peasant -= run_trained_peasant
      end
    end

    def calculate_battle_points
      @total_attack_army = @attack_swordsman + @attack_archer + @attack_horseman + @attack_trained_peasant + @attack_macemen + @attack_unique_unit

      @attack_points = (
        @attack_swordsman * data[:soldiers][:swordsman][:settings][:attack_points] +
        @attack_archer * data[:soldiers][:archer][:settings][:attack_points] +
        @attack_horseman * data[:soldiers][:horseman][:settings][:attack_points] +
        @attack_trained_peasant * data[:soldiers][:trained_peasant][:settings][:attack_points] +
        @attack_macemen * data[:soldiers][:macemen][:settings][:attack_points] +
        @attack_unique_unit * data[:soldiers][:unique_unit][:settings][:attack_points]
      )
      @attack_points = (@attack_points + @attack_points * (user_game.attack_points_researches / 100.0)).round

      if attack_queue.cost_wine.to_i > 0 && @total_attack_army > 0
        percent_wine = attack_queue.cost_wine.to_f / @total_attack_army
        @attack_points = (@attack_points + @attack_points * percent_wine).round
      end

      apply_attack_penalties

      @defense_points = (
        @defense_swordsman * defender_soldiers[:swordsman][:settings][:defense_points] +
        @defense_archer * defender_soldiers[:archer][:settings][:defense_points] +
        @defense_horseman * defender_soldiers[:horseman][:settings][:defense_points] +
        @defense_trained_peasant * defender_soldiers[:trained_peasant][:settings][:defense_points] +
        @defense_macemen * defender_soldiers[:macemen][:settings][:defense_points] +
        @defense_unique_unit * defender_soldiers[:unique_unit][:settings][:defense_points]
        @defense_tower * defender_soldiers[:tower][:settings][:defense_points]
      )
      @defense_points = (@defense_points * (1 + defender.defense_points_researches / 100.0)).round

      add_wall_defense
      randomize_battle_points
    end

    def apply_attack_penalties
      case has_attacks
      when 3..4
        @victory_points *= 0.80
        @attack_points = (@attack_points * 0.92).round
      when 5..7
        @victory_points *= 0.65
        @attack_points = (@attack_points * 0.84).round
      when 8..9
        @victory_points *= 0.50
        @attack_points = (@attack_points * 0.76).round
      when 10..11
        @victory_points *= 0.35
        @attack_points = (@attack_points * 0.68).round
      when 12..14
        @victory_points *= 0.20
        @attack_points = (@attack_points * 0.60).round
      when 15..Float::INFINITY
        @victory_points *= 0.01
        @attack_points = (@attack_points * 0.25).round
        @attack_message << "#{defender.user.name} was attacked too many times in the past 24 hours. <br>#{user_game.user.name} army is weakened!!!!"
      end
    end

    def add_wall_defense
      total_land = defender.m_land + defender.f_land + defender.p_land
      total_wall = (total_land * UserGame::WALL_MULTIPLIER).round

      if total_wall > 0 && defender.wall > 0
        protection = defender.wall.to_f / total_wall
        protection = 1.0 if protection > 1.0 # Cap at 100%
        @defense_points = (@defense_points + @defense_points * protection).round
        @attack_message << "Great Wall provides #{(protection * 100).round}% extra defense!"
      end
    end

    def randomize_battle_points
      a_start = @attack_points - (@attack_points * 0.1).round
      a_end = @attack_points + (@attack_points * 0.1).round
      d_start = @defense_points - (@defense_points * 0.1).round
      d_end = @defense_points + (@defense_points * 0.1).round

      # Handle potential overflow for very large numbers
      if a_start > 2_000_000_000 || a_end > 2_000_000_000
        a_start = (a_start / 100).round
        a_end = (a_end / 100).round
        @attack_points = (rand(a_start..a_end) * 100).round
      else
        @attack_points = rand(a_start..a_end)
      end

      if d_start > 2_000_000_000 || d_end > 2_000_000_000
        d_start = (d_start / 100).round
        d_end = (d_end / 100).round
        @defense_points = (rand(d_start..d_end) * 100).round
      else
        @defense_points = rand(d_start..d_end)
      end
    end

    def determine_casualties
      # Calculate defender casualties
      d_total_army = @defense_swordsman + @defense_archer + @defense_horseman + @defense_trained_peasant + @defense_macemen + @defense_unique_unit

      if defender.score < user_game.score
        a_killed = (@defense_points / 300.0).round
        d_killed = ((@attack_points / 300.0) * @victory_points).round
        t_killed = ((@attack_points / 3000.0) * @victory_points).round
      else
        a_killed = (@defense_points / 150.0).round
        d_killed = ((@attack_points / 150.0) * @victory_points).round
        t_killed = ((@attack_points / 1500.0) * @victory_points).round
      end

      if defender.military_losses_researches <= 50
        heal = (defender.military_losses_researches / 100.0) * d_killed
        d_killed = (d_killed - heal).round
      end

      # Calculate casualties by unit type
      if d_killed >= d_total_army || d_total_army == 0
        d_killed_percent = 1.0
      else
        d_killed_percent = d_killed.to_f / d_total_army
      end

      if user_game.military_losses_researches <= 50
        heal = (user_game.military_losses_researches / 100.0) * a_killed
        a_killed = (a_killed - heal).round
      end

      if a_killed >= @total_attack_army || @total_attack_army == 0
        a_killed_percent = 1.0
      else
        a_killed_percent = a_killed.to_f / @total_attack_army
      end

      @d_die_archer = (@defense_archer * d_killed_percent).round
      @d_die_swordsman = (@defense_swordsman * d_killed_percent).round
      @d_die_horseman = (@defense_horseman * d_killed_percent).round
      @d_die_trained_peasant = (@defense_trained_peasant * d_killed_percent).round
      @d_die_macemen = (@defense_macemen * d_killed_percent).round
      @d_die_unique_unit = (@defense_unique_unit * d_killed_percent).round
      @d_die_tower = t_killed

      # Ensure casualties don't exceed available units
      @d_die_archer = [@d_die_archer, @defense_archer].min
      @d_die_swordsman = [@d_die_swordsman, @defense_swordsman].min
      @d_die_horseman = [@d_die_horseman, @defense_horseman].min
      @d_die_trained_peasant = [@d_die_trained_peasant, @defense_trained_peasant].min
      @d_die_macemen = [@d_die_macemen, @defense_macemen].min
      @d_die_unique_unit = [@d_die_unique_unit, @defense_unique_unit].min
      @d_die_tower = [@d_die_tower, @defense_tower].min

      # Apply casualties
      @defense_archer -= @d_die_archer
      @defense_swordsman -= @d_die_swordsman
      @defense_horseman -= @d_die_horseman
      @defense_trained_peasant -= @d_die_trained_peasant
      @defense_macemen -= @d_die_macemen
      @defense_unique_unit -= @d_die_unique_unit
      @defense_tower -= @d_die_tower

      @a_die_archer = (@attack_archer * a_killed_percent).round
      @a_die_swordsman = (@attack_swordsman * a_killed_percent).round
      @a_die_horseman = (@attack_horseman * a_killed_percent).round
      @a_die_trained_peasant = (@attack_trained_peasant * a_killed_percent).round
      @a_die_macemen = (@attack_macemen * a_killed_percent).round
      @a_die_unique_unit = (@attack_unique_unit * a_killed_percent).round

      # Ensure casualties don't exceed available units
      @a_die_archer = [@a_die_archer, @attack_archer].min
      @a_die_swordsman = [@a_die_swordsman, @attack_swordsman].min
      @a_die_horseman = [@a_die_horseman, @attack_horseman].min
      @a_die_trained_peasant = [@a_die_trained_peasant, @attack_trained_peasant].min
      @a_die_macemen = [@a_die_macemen, @attack_macemen].min
      @a_die_unique_unit = [@a_die_unique_unit, @attack_unique_unit].min

      # Apply casualties
      @attack_archer -= @a_die_archer
      @attack_swordsman -= @a_die_swordsman
      @attack_horseman -= @a_die_horseman
      @attack_trained_peasant -= @a_die_trained_peasant
      @attack_macemen -= @a_die_macemen
      @attack_unique_unit -= @a_die_unique_unit
      
      build_casualties_message
    end

    def build_casualties_message
      @attack_message << "#{user_game.user.name} killed:"
      killed_total = @d_die_unique_unit + @d_die_horseman + @d_die_swordsman + @d_die_archer + @d_die_macemen + @d_die_trained_peasant

      @attack_message << "#{defender_soldiers[:unique_unit][:name]}: #{@d_die_unique_unit}" if @d_die_unique_unit > 0
      @attack_message << "Horseman: #{@d_die_horseman}" if @d_die_horseman > 0
      @attack_message << "Swordsman: #{@d_die_swordsman}" if @d_die_swordsman > 0
      @attack_message << "Archers: #{@d_die_archer}" if @d_die_archer > 0
      @attack_message << "Macemen: #{@d_die_macemen}" if @d_die_macemen > 0
      @attack_message << "Trained Peasants: #{@d_die_trained_peasant}" if @d_die_trained_peasant > 0
      @attack_message << 'No Kills' if killed_total == 0
      @attack_message << "Towers Razed: #{@d_die_tower}" if @d_die_tower > 0

      @attack_message << "#{defender.user.name} killed:"
      killed_total = @a_die_unique_unit + @a_die_horseman + @a_die_swordsman + @d_die_archer + @a_die_macemen + @d_die_trained_peasant

      @attack_message << "#{data[:soldiers][:unique_unit][:name]}: #{@a_die_unique_unit}" if @a_die_unique_unit > 0
      @attack_message << "Horseman: #{@a_die_horseman}" if @a_die_horseman > 0
      @attack_message << "Swordsman: #{@a_die_swordsman}" if @a_die_swordsman > 0
      @attack_message << "Archers: #{@a_die_archer}" if @a_die_archer > 0
      @attack_message << "Macemen: #{@a_die_macemen}" if @a_die_macemen > 0
      @attack_message << "Trained Peasants: #{@a_die_trained_peasant}" if @a_die_trained_peasant > 0
      @attack_message << 'No Kills' if killed_total == 0
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
      when 'army_conquer'
        process_conquer_attack
      when 'army_raid'
        process_raid_attack
        # when 2
        #   process_rob_attack
        # when 3
        #   process_slaughter_attack
      end
    end

    def process_conquer_attack
      # Calculate land that can be taken
      attack_points = (
        @attack_swordsman * data[:soldiers][:swordsman][:settings][:take_land] +
        @attack_archer * data[:soldiers][:archer][:settings][:take_land] +
        @attack_horseman * data[:soldiers][:horseman][:settings][:take_land] +
        @attack_macemen * data[:soldiers][:macemen][:settings][:take_land] +
        @attack_trained_peasant * data[:soldiers][:trained_peasant][:settings][:take_land] +
        @attack_unique_unit * data[:soldiers][:unique_unit][:settings][:take_land]
      ) * @victory_points

      return if attack_points <= 0

      take_land = rand((attack_points / 2).round..attack_points) + 1

      d_total_land = defender.m_land + defender.p_land + defender.f_land

      # Calculate land percentages
      m_percent = d_total_land > 0 ? defender.m_land.to_f / d_total_land : 0
      f_percent = d_total_land > 0 ? defender.f_land.to_f / d_total_land : 0
      p_percent = d_total_land > 0 ? defender.p_land.to_f / d_total_land : 0

      take_m = (take_land * m_percent).round
      take_f = (take_land * f_percent).round
      take_p = (take_land * p_percent).round

      # Ensure we don't take more than available
      take_m = [defender.m_land, take_m].min
      take_f = [defender.f_land, take_f].min
      take_p = [defender.p_land, take_p].min

      # Transfer land
      defender.m_land -= take_m
      defender.f_land -= take_f
      defender.p_land -= take_p

      # @stolen_resources[:m_land] = take_m
      # @stolen_resources[:f_land] = take_f
      # @stolen_resources[:p_land] = take_p

      @attack_message << "#{user_game.user.name} conquered #{take_m} mountains, #{take_f} forest and #{take_p} plain land"

      # Handle building destruction due to insufficient land
      handle_building_destruction_from_land_loss
    end

    def handle_building_destruction_from_land_loss
      buildings = PrepareBuildingsDataCommand.new(
        game: defender.game, civilization: defender.civilization
      ).call.with_indifferent_access

      # Check mountain buildings
      need_m_land = defender.iron_mine * buildings[:iron_mine][:settings][:squares] +
                    defender.gold_mine * buildings[:gold_mine][:settings][:squares]

      if defender.m_land <= 0
        defender.iron_mine = 0
        defender.gold_mine = 0
      elsif need_m_land > defender.m_land
        defender.iron_mine = (
          (
            ((defender.iron_mine * buildings[:iron_mine][:settings][:squares]).to_f / need_m_land) * defender.m_land
          ) / buildings[:iron_mine][:settings][:squares]
        ).floor
        defender.gold_mine = (
          (
            ((defender.gold_mine * buildings[:gold_mine][:settings][:squares]).to_f / need_m_land) * defender.m_land
          ) / buildings[:gold_mine][:settings][:squares]
        ).floor
      end

      # Check forest buildings
      need_f_land = defender.wood_cutter * buildings[:wood_cutter][:settings][:squares] +
                    defender.hunter * buildings[:hunter][:settings][:squares]

      if defender.f_land <= 0
        defender.wood_cutter = 0
        defender.hunter = 0
      elsif need_f_land > defender.f_land
        defender.wood_cutter = (
          (
            ((defender.wood_cutter * buildings[:wood_cutter][:settings][:squares]).to_f / need_f_land) * defender.f_land
          ) / buildings[:wood_cutter][:settings][:squares]
        ).floor
        defender.hunter = (
          (
            ((defender.hunter * buildings[:hunter][:settings][:squares]).to_f / need_f_land) * defender.f_land
          ) / buildings[:hunter][:settings][:squares]
        ).floor
      end

      plain_buildings = [
        :farm, :house, :tool_maker, :weaponsmith, :fort, :tower, :town_center, :market, :warehouse, :stable,
        :mage_tower, :winery
      ]
      need_p_land = plain_buildings.sum { |key| defender.send(key) * buildings[key][:settings][:squares] }

      if defender.p_land <= 0
        plain_buildings.each { |building| defender.send("#{building}=", 0) }
      elsif need_p_land > defender.p_land
        plain_buildings.each do |key|
          current_count = defender.send(key)
          new_count = (
            (
              (current_count * buildings[key][:settings][:squares]).to_f / need_p_land
            ) * defender.p_land / buildings[key][:settings][:squares]
          ).floor
          defender.send("#{key}=", new_count)
        end
      end

      # Adjust wall based on remaining land
      total_land = defender.m_land + defender.f_land + defender.p_land
      total_wall = (total_land * UserGame::WALL_MULTIPLIER).round
      defender.wall = [defender.wall, total_wall].min
    end

    def process_raid_attack
      attack_points = (
        @attack_swordsman * 0.05 +
        @attack_archer * 0.04 +
        @attack_horseman * 0.1 +
        @attack_macemen * 0.03 +
        @attack_trained_peasant * 0.01
      ) * @victory_points * 0.1

      attack_points = attack_points.round

      building_fields = data[:buildings].keys
      d_total_buildings = building_fields.sum { |field| defender.send(field) }

      if attack_points > 0 && d_total_buildings > 0
        casualties = {}
        building_fields.each do |field|
          field_value = defender.send(field)
          casualty = ((field_value.to_f / d_total_buildings) * attack_points).round
          casualty = [casualty, field_value].min
          casualties[field] = casualty
          defender.send("#{field}=", field_value - casualty)
        end

        parts = casualties.map { |field, count| "#{count} #{data[:buildings][field][:name]}" }
        @attack_message << "#{user_game.user.name} destroyed #{parts.join(', ')}<br>"
      else
        @attack_message << 'But failed to destroy any building'
      end
    end

    def process_rob_attack
      attack_points = (
        @attack_swordsman * 1.0 +
        @attack_archers * 0.9 +
        @attack_horseman * 1.5 +
        @attack_macemen * 0.5 +
        @attack_peasants * 0.1
      ) * @victory_points * 0.5

      attack_points = attack_points.floor
      d_total_goods = @defense_player.wood + @defense_player.food + @defense_player.iron + (@defense_player.gold / 100).floor

      if attack_points > 0 && d_total_goods > 0
        p_wood = @defense_player.wood.to_f / d_total_goods
        p_iron = @defense_player.iron.to_f / d_total_goods
        p_food = @defense_player.food.to_f / d_total_goods
        p_gold = (@defense_player.gold / 100.0) / d_total_goods

        take_wood = (attack_points * p_wood).round
        take_iron = (attack_points * p_iron).round
        take_food = (attack_points * p_food).round
        take_gold = (attack_points * p_gold).round * 25

        # Ensure we don't take more than available
        take_wood = [@defense_player.wood, take_wood].min
        take_iron = [@defense_player.iron, take_iron].min
        take_food = [@defense_player.food, take_food].min
        take_gold = [@defense_player.gold, take_gold].min

        # Remove from defender
        @defense_player.wood -= take_wood
        @defense_player.iron -= take_iron
        @defense_player.food -= take_food
        @defense_player.gold -= take_gold

        # Add to stolen resources
        @stolen_resources[:wood] = take_wood
        @stolen_resources[:food] = take_food
        @stolen_resources[:iron] = take_iron
        @stolen_resources[:gold] = take_gold

        @news_message = "#{take_wood + take_food + take_iron} goods <br>and #{take_gold} gold"
        @attack_message += "#{user_game.user.name} robbed #{take_wood} wood, #{take_iron} iron, #{take_food} food and #{take_gold} gold<br>"
      else
        @news_message = '0 Goods'
        @attack_message += 'But failed to take any goods<br>'
      end
    end

    def process_slaughter_attack
      attack_points = (
        @attack_swordsman * 1.0 +
        @attack_archers * 0.9 +
        @attack_horseman * 1.5 +
        @attack_macemen * 0.5 +
        @attack_peasants * 0.1
      ) * @victory_points * 0.5

      attack_points = attack_points.round

      if attack_points > 0 && @defense_player.people > 0
        kill_people = [attack_points, @defense_player.people].min
        @defense_player.people = [@defense_player.people - kill_people, UserGame::MIN_PEOPLE].max

        @news_message = "#{kill_people} people"
        @attack_message += "#{user_game.user.name} slaughtered #{kill_people} people<br>"
      else
        @news_message = 'No kills'
        @attack_message += 'But failed to kill any people<br>'
      end
    end

    def update_databases
      attack_queue.update!(
        swordsman_soldiers: @attack_swordsman,
        archer_soldiers: @attack_archer,
        horseman_soldiers: @attack_horseman,
        macemen_soldiers: @attack_macemen,
        trained_peasant_soldiers: @attack_trained_peasant,
        unique_unit_soldiers: @attack_unique_unit
      )

      # TODO: Add logic to kill the user if land is 0

      # Ensure minimum people count
      defender.people = [defender.people, UserGame::MIN_PEOPLE].max
      defender.assign_attributes(
        tower: @defense_tower,
        swordsman_soldiers: @defense_swordsman,
        archer_soldiers: @defense_archer,
        horseman_soldiers: @defense_horseman,
        macemen_soldiers: @defense_macemen,
        trained_peasant_soldiers: @defense_trained_peasant,
        unique_unit_soldiers: @defense_unique_unit,
        updated_at: Time.current
      )
      defender.save!

      @attack_message = @attack_message.join("\n")
    end

    def record_battle_news
      AttackLog.create!(
        attacker_id: user_game.id,
        defender_id: defender.id,
        attack_type: attack_queue.attack_type,
        attacker_wins: @attacker_wins,
        casualties: {
          unique_unit: { attacker: @a_die_unique_unit, defender: @d_die_unique_unit },
          archer: { attacker: @a_die_archer, defender: @d_die_archer },
          swordsman: { attacker: @a_die_swordsman, defender: @d_die_swordsman },
          horseman: { attacker: @a_die_horseman, defender: @d_die_horseman },
          macemen: { attacker: @a_die_macemen, defender: @d_die_macemen },
          trained_peasant: { attacker: @a_die_trained_peasant, defender: @d_die_trained_peasant },
          tower: { defender: @d_die_tower }
        },
        attack_message: @attack_message,
      )
    end

    def get_building_squares_for_civilization(civilization_id)
      base_squares = {
        iron_mine: 2, gold_mine: 6, wood_cutter: 4, hunter: 2, farm: 4,
        house: 2, tool_maker: 2, weaponsmith: 4, fort: 12, tower: 4,
        town_center: 25, market: 4, warehouse: 2, stable: 4,
        mage_tower: 10, winery: 6
      }

      case civilization_id
      when 1 # viking
        base_squares[:stable] = 6
        base_squares[:wood_cutter] = 3
      when 2 # franks
        base_squares[:town_center] = 35
        base_squares[:mage_tower] = 12
        base_squares[:farm] = 2
        base_squares[:tower] = 3
      when 3 # japanese
        base_squares[:wood_cutter] = 5
        base_squares[:stable] = 8
        base_squares[:town_center] = 20
      when 4 # byzantines
        base_squares[:iron_mine] = 3
        base_squares[:gold_mine] = 2
        base_squares[:town_center] = 22
        base_squares[:mage_tower] = 8
      when 5 # mongols
        base_squares[:fort] = 8
      when 6 # incas
        base_squares[:iron_mine] = 3
        base_squares[:town_center] = 30
      when 7 # chinese
        base_squares[:tower] = 3
        base_squares[:winery] = 8
        base_squares[:house] = 4
        base_squares[:farm] = 5
      end

      base_squares
    end
  end
end
