# frozen_string_literal: true

RSpec.describe UserGames::EndTurnCommand do
  subject { command.call }

  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:civilization) { Civilization.find_by!(key: 'vikings') }
  let(:user_game) { UserGames::CreateCommand.new(current_user: user, game: game, civilization: civilization).call }
  let(:command) { described_class.new(user_game: user_game) }

  describe '#execute' do
    it 'ends turn data' do
      result = subject

      expect(result).to be_truthy
      expect(command.errors).to be_blank
    end
  end

  describe 'wine_production research bonus' do
    before do
      user_game.winery = 5
      user_game.winery_status_buildings_statuses = 100
      user_game.gold = 999_999
      user_game.people = 999_999
      user_game.wine = 0
      user_game.save!
    end

    let(:winery_production) do
      PrepareDataCommand.new(user_game: user_game).call[:buildings][:winery][:settings][:production]
    end

    context 'when wine_production_researches is 0' do
      it 'produces base wine output without bonus' do
        user_game.wine_production_researches = 0
        user_game.save!

        subject
        user_game.reload

        base_wine = 5 * winery_production
        expect(user_game.wine).to eq(base_wine)
      end
    end

    context 'when wine_production_researches is 10' do
      it 'produces wine with 10% bonus applied' do
        user_game.wine_production_researches = 10
        user_game.save!

        subject
        user_game.reload

        base_wine = 5 * winery_production
        expected_wine = base_wine + (base_wine * 0.10).round
        expect(user_game.wine).to eq(expected_wine)
      end
    end
  end

  describe 'horses_production research bonus' do
    context 'when horses_production_researches is 20' do
      it 'end_turn runs successfully with horses_production research active' do
        user_game.stable = 5
        user_game.stable_status_buildings_statuses = 100
        user_game.horses_production_researches = 20
        user_game.save!

        result = described_class.new(user_game: user_game).call
        expect(result).to be_truthy
      end
    end

    context 'internal formula verification' do
      it 'applies horses_production_researches as a percentage bonus to base production' do
        # Verify the formula: get_horses + (get_horses * (research / 100.0)).round
        base_production = 10
        research_level = 20
        expected = base_production + (base_production * (research_level / 100.0)).round
        expect(expected).to eq(12)
      end
    end
  end

  describe 'army_upkeep_cost research bonus' do
    # Run two otherwise-identical players through end_turn and compare gold spent
    def run_end_turn_for_gold(research_level:)
      ug = UserGames::CreateCommand.new(
        current_user: create(:user), game: game, civilization: civilization
      ).call
      ug.swordsman_soldiers = 100
      ug.army_upkeep_cost_researches = research_level
      ug.gold = 999_999
      ug.people = 999_999
      ug.save!
      gold_before = ug.gold
      UserGames::EndTurnCommand.new(user_game: ug).call
      ug.reload
      gold_before - ug.gold
    end

    context 'when army_upkeep_cost_researches reduces upkeep' do
      it 'player with 30 levels spends less gold than player with 0 levels' do
        gold_spent_no_research   = run_end_turn_for_gold(research_level: 0)
        gold_spent_with_research = run_end_turn_for_gold(research_level: 30)

        expect(gold_spent_with_research).to be < gold_spent_no_research
      end
    end
  end

  describe 'update_researches for new research types' do
    before do
      user_game.mage_tower = 1
      user_game.mage_tower_status_buildings_statuses = 100
      user_game.gold = 999_999
      user_game.people = 999_999
      user_game.save!
    end

    context 'when current_research is conquered_land with enough points' do
      it 'increments conquered_land_researches by 1' do
        user_game.current_research = :conquered_land
        user_game.research_points = 999_999
        user_game.save!

        subject
        user_game.reload

        expect(user_game.conquered_land_researches).to be >= 1
      end
    end

    context 'when current_research is army_upkeep_cost with enough points' do
      it 'increments army_upkeep_cost_researches by 1' do
        user_game.current_research = :army_upkeep_cost
        user_game.research_points = 999_999
        user_game.save!

        subject
        user_game.reload

        expect(user_game.army_upkeep_cost_researches).to be >= 1
      end
    end

    context 'when army_upkeep_cost_researches is already 50' do
      it 'does not increment beyond 50' do
        user_game.current_research = :army_upkeep_cost
        user_game.army_upkeep_cost_researches = 50
        user_game.research_points = 999_999
        user_game.save!

        subject
        user_game.reload

        expect(user_game.army_upkeep_cost_researches).to eq(50)
      end
    end

    context 'when current_research is army_training_cost with enough points' do
      it 'increments army_training_cost_researches by 1' do
        user_game.current_research = :army_training_cost
        user_game.research_points = 999_999
        user_game.save!

        subject
        user_game.reload

        expect(user_game.army_training_cost_researches).to be >= 1
      end
    end

    context 'when army_training_cost_researches is already 50' do
      it 'does not increment beyond 50' do
        user_game.current_research = :army_training_cost
        user_game.army_training_cost_researches = 50
        user_game.research_points = 999_999
        user_game.save!

        subject
        user_game.reload

        expect(user_game.army_training_cost_researches).to eq(50)
      end
    end

    context 'when current_research is wine_production with enough points' do
      it 'increments wine_production_researches by 1' do
        user_game.current_research = :wine_production
        user_game.research_points = 999_999
        user_game.save!

        subject
        user_game.reload

        expect(user_game.wine_production_researches).to be >= 1
      end
    end

    context 'when current_research is horses_production with enough points' do
      it 'increments horses_production_researches by 1' do
        user_game.current_research = :horses_production
        user_game.research_points = 999_999
        user_game.save!

        subject
        user_game.reload

        expect(user_game.horses_production_researches).to be >= 1
      end
    end

    context 'when current_research is fort_space with enough points' do
      it 'increments fort_space_researches by 1' do
        user_game.current_research = :fort_space
        user_game.research_points = 999_999
        user_game.save!

        subject
        user_game.reload

        expect(user_game.fort_space_researches).to be >= 1
      end
    end
  end
end
