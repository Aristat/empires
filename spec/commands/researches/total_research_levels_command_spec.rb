# frozen_string_literal: true

RSpec.describe Researches::TotalResearchLevelsCommand do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:civilization) { Civilization.find_by!(key: 'vikings') }
  let(:user_game) { UserGames::CreateCommand.new(current_user: user, game: game, civilization: civilization).call }

  describe '#call' do
    it 'returns 0 when no researches have been done' do
      result = described_class.new(user_game: user_game).call
      expect(result).to eq(0)
    end

    it 'sums all existing research levels' do
      user_game.attack_points_researches = 5
      user_game.defense_points_researches = 3
      user_game.wood_production_researches = 2

      result = described_class.new(user_game: user_game).call
      expect(result).to eq(10)
    end

    it 'includes conquered_land_researches in the sum' do
      user_game.conquered_land_researches = 7

      result = described_class.new(user_game: user_game).call
      expect(result).to eq(7)
    end

    it 'includes army_upkeep_cost_researches in the sum' do
      user_game.army_upkeep_cost_researches = 10

      result = described_class.new(user_game: user_game).call
      expect(result).to eq(10)
    end

    it 'includes army_training_cost_researches in the sum' do
      user_game.army_training_cost_researches = 15

      result = described_class.new(user_game: user_game).call
      expect(result).to eq(15)
    end

    it 'includes wine_production_researches in the sum' do
      user_game.wine_production_researches = 4

      result = described_class.new(user_game: user_game).call
      expect(result).to eq(4)
    end

    it 'includes horses_production_researches in the sum' do
      user_game.horses_production_researches = 6

      result = described_class.new(user_game: user_game).call
      expect(result).to eq(6)
    end

    it 'includes fort_space_researches in the sum' do
      user_game.fort_space_researches = 8

      result = described_class.new(user_game: user_game).call
      expect(result).to eq(8)
    end

    it 'sums all 18 research types together' do
      user_game.attack_points_researches = 1
      user_game.defense_points_researches = 1
      user_game.thieves_strength_researches = 1
      user_game.military_losses_researches = 1
      user_game.food_production_researches = 1
      user_game.mine_production_researches = 1
      user_game.weapons_tools_production_researches = 1
      user_game.space_effectiveness_researches = 1
      user_game.markets_output_researches = 1
      user_game.explorers_researches = 1
      user_game.catapults_strength_researches = 1
      user_game.wood_production_researches = 1
      user_game.conquered_land_researches = 1
      user_game.army_upkeep_cost_researches = 1
      user_game.army_training_cost_researches = 1
      user_game.wine_production_researches = 1
      user_game.horses_production_researches = 1
      user_game.fort_space_researches = 1

      result = described_class.new(user_game: user_game).call
      expect(result).to eq(18)
    end
  end
end
