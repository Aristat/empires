# frozen_string_literal: true

RSpec.describe TrainQueues::SoldiersLimitCommand do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:civilization) { Civilization.find_by!(key: 'vikings') }
  let(:user_game) do
    UserGames::CreateCommand.new(current_user: user, game: game, civilization: civilization).call
  end
  let(:buildings) do
    PrepareBuildingsDataCommand.new(game: game, civilization: civilization).call.with_indifferent_access
  end

  describe '#call' do
    before do
      user_game.fort = 10
      user_game.town_center = 5
      user_game.save!
    end

    context 'when fort_space_researches is 0' do
      it 'returns base capacity (town_center + fort)' do
        user_game.fort_space_researches = 0
        user_game.save!

        fort_max = buildings[:fort][:settings][:max_units]
        town_center_max = buildings[:town_center][:settings][:max_units]
        expected = 5 * town_center_max + 10 * fort_max

        result = described_class.new(user_game: user_game, buildings: buildings).call
        expect(result).to eq(expected)
      end
    end

    context 'when fort_space_researches is 20' do
      it 'increases fort capacity by 20%' do
        user_game.fort_space_researches = 20
        user_game.save!

        fort_max = buildings[:fort][:settings][:max_units]
        town_center_max = buildings[:town_center][:settings][:max_units]
        base_fort_capacity = 10 * fort_max
        boosted_fort_capacity = base_fort_capacity + (base_fort_capacity * 0.20).round
        expected = 5 * town_center_max + boosted_fort_capacity

        result = described_class.new(user_game: user_game, buildings: buildings).call
        expect(result).to eq(expected)
      end
    end

    context 'when fort_space_researches is 50' do
      it 'increases fort capacity by 50%' do
        user_game.fort_space_researches = 50
        user_game.save!

        fort_max = buildings[:fort][:settings][:max_units]
        town_center_max = buildings[:town_center][:settings][:max_units]
        base_fort_capacity = 10 * fort_max
        boosted_fort_capacity = base_fort_capacity + (base_fort_capacity * 0.50).round
        expected = 5 * town_center_max + boosted_fort_capacity

        result = described_class.new(user_game: user_game, buildings: buildings).call
        expect(result).to eq(expected)
      end
    end

    context 'town_center capacity is unaffected by fort_space_researches' do
      it 'town_center contributes the same regardless of fort_space level' do
        town_center_max = buildings[:town_center][:settings][:max_units]
        fort_max = buildings[:fort][:settings][:max_units]

        user_game.fort_space_researches = 0
        user_game.save!
        result_no_research = described_class.new(user_game: user_game, buildings: buildings).call

        user_game.fort_space_researches = 100
        user_game.save!
        result_with_research = described_class.new(user_game: user_game, buildings: buildings).call

        # Difference should only be from fort capacity change
        base_fort = 10 * fort_max
        expected_diff = (base_fort * 1.00).round
        expect(result_with_research - result_no_research).to eq(expected_diff)
      end
    end

    context 'when there are no forts' do
      it 'returns only town_center capacity unchanged' do
        user_game.fort = 0
        user_game.fort_space_researches = 50
        user_game.save!

        town_center_max = buildings[:town_center][:settings][:max_units]
        expected = 5 * town_center_max

        result = described_class.new(user_game: user_game, buildings: buildings).call
        expect(result).to eq(expected)
      end
    end
  end
end
