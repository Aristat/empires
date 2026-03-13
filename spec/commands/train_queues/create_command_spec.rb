# frozen_string_literal: true

RSpec.describe TrainQueues::CreateCommand do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:civilization) { Civilization.find_by!(key: 'vikings') }
  let(:user_game) do
    UserGames::CreateCommand.new(current_user: user, game: game, civilization: civilization).call
  end

  def make_command(params)
    described_class.new(user_game: user_game, train_queue_params: params)
  end

  describe '#call' do
    context 'training trained_peasant (zero resource cost)' do
      let(:train_params) { { 'trained_peasant' => '5' } }

      it 'creates a train queue' do
        expect { make_command(train_params).call }.to change { user_game.train_queues.count }.by(1)
      end

      it 'returns truthy' do
        expect(make_command(train_params).call).to be_truthy
      end

      it 'deducts people' do
        people_before = user_game.people
        make_command(train_params).call
        user_game.reload
        expect(user_game.people).to eq(people_before - 5)
      end
    end

    context 'army_training_cost research discount' do
      before do
        user_game.gold = 999_999
        user_game.iron = 999_999
        user_game.swords = 999_999
        user_game.save!
      end

      context 'when army_training_cost_researches is 0' do
        before { user_game.army_training_cost_researches = 0; user_game.save! }

        it 'deducts full gold cost for swordsman training' do
          soldiers_data = PrepareSoldiersDataCommand.new(
            game: game, civilization: civilization
          ).call.with_indifferent_access
          train_gold = soldiers_data[:swordsman][:settings][:train_gold]
          quantity = 10

          gold_before = user_game.gold
          make_command({ 'swordsman' => quantity.to_s }).call
          user_game.reload

          expected_cost = train_gold * quantity
          expect(gold_before - user_game.gold).to eq(expected_cost)
        end
      end

      context 'when army_training_cost_researches is 25' do
        before { user_game.army_training_cost_researches = 25; user_game.save! }

        it 'applies 25% discount to gold training cost' do
          soldiers_data = PrepareSoldiersDataCommand.new(
            game: game, civilization: civilization
          ).call.with_indifferent_access
          train_gold = soldiers_data[:swordsman][:settings][:train_gold]
          quantity = 10

          gold_before = user_game.gold
          make_command({ 'swordsman' => quantity.to_s }).call
          user_game.reload

          base_cost = train_gold * quantity
          discounted_cost = (base_cost - (base_cost * 0.25)).round
          expect(gold_before - user_game.gold).to eq(discounted_cost)
        end
      end

      context 'when army_training_cost_researches is 50' do
        before { user_game.army_training_cost_researches = 50; user_game.save! }

        it 'applies 50% discount to gold training cost' do
          soldiers_data = PrepareSoldiersDataCommand.new(
            game: game, civilization: civilization
          ).call.with_indifferent_access
          train_gold = soldiers_data[:swordsman][:settings][:train_gold]
          quantity = 10

          gold_before = user_game.gold
          make_command({ 'swordsman' => quantity.to_s }).call
          user_game.reload

          base_cost = train_gold * quantity
          discounted_cost = (base_cost - (base_cost * 0.50)).round
          expect(gold_before - user_game.gold).to eq(discounted_cost)
        end
      end

      context 'when player has insufficient resources without discount but sufficient with it' do
        it 'allows training when discount makes cost affordable' do
          soldiers_data = PrepareSoldiersDataCommand.new(
            game: game, civilization: civilization
          ).call.with_indifferent_access
          train_gold = soldiers_data[:swordsman][:settings][:train_gold]
          quantity = 10
          base_cost = train_gold * quantity

          # Set gold to just below base cost but above discounted cost (50% off)
          discounted_cost = (base_cost - (base_cost * 0.50)).round
          user_game.gold = discounted_cost
          user_game.army_training_cost_researches = 50
          user_game.save!

          command = make_command({ 'swordsman' => quantity.to_s })
          command.call

          expect(command.errors).to be_blank
        end
      end
    end
  end
end
