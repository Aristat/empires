# frozen_string_literal: true

RSpec.describe ExploreQueues::CreateCommand do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:civilization) { Civilization.find_by!(key: 'vikings') }
  let(:user_game) do
    UserGames::CreateCommand.new(current_user: user, game: game, civilization: civilization).call
  end

  # Default user_game after CreateCommand:
  #   people: 3000, food: 2500, horses: 0, town_center: 10
  #   max_explorers = town_center(10) * max_explorers_per(6) = 60
  #   food_per_explorer ≈ 5 (base) + ceil(4000/800) = 10
  #   sending 5 people: food_needed = 50

  let(:valid_params) do
    {
      quantity: '5',
      horse_setting: 'without_horses',
      seek_land: 'all_land'
    }
  end

  def make_command(params)
    described_class.new(user_game: user_game, explore_queue_params: params)
  end

  describe '#call' do
    context 'with valid params and sufficient resources' do
      it 'has no errors' do
        command = make_command(valid_params)
        command.call
        expect(command.errors).to be_empty
      end

      it 'creates an explore queue record' do
        expect { make_command(valid_params).call }
          .to change { user_game.explore_queues.count }.by(1)
      end

      it 'deducts people and food from user_game' do
        original_people = user_game.people
        original_food = user_game.food
        make_command(valid_params).call
        user_game.reload
        expect(user_game.people).to eq(original_people - 5)
        expect(user_game.food).to be < original_food
      end

      it 'stores people, seek_land, and horse_setting on the queue' do
        make_command(valid_params).call
        queue = user_game.explore_queues.last
        expect(queue.people).to eq(5)
        expect(queue.horse_setting).to eq('without_horses')
        expect(queue.seek_land).to eq('all_land')
      end

      it 'sets trip length to 6 turns (no horses)' do
        make_command(valid_params).call
        expect(user_game.explore_queues.last.turn).to eq(6)
      end

      it 'sets turns_used to 0' do
        make_command(valid_params).call
        expect(user_game.explore_queues.last.turns_used).to eq(0)
      end
    end

    context 'with horse_setting: one_horse' do
      before { user_game.update!(horses: 100) }

      let(:params) { valid_params.merge(horse_setting: 'one_horse') }

      it 'creates the queue with trip length 8' do
        make_command(params).call
        expect(user_game.explore_queues.last.turn).to eq(8)
      end

      it 'uses quantity horses and deducts from user_game' do
        original_horses = user_game.horses
        make_command(params).call
        user_game.reload
        # one_horse: horses = quantity (5)
        expect(user_game.horses).to eq(original_horses - 5)
      end
    end

    context 'with horse_setting: two_horses' do
      before { user_game.update!(horses: 100) }

      let(:params) { valid_params.merge(horse_setting: 'two_horses') }

      it 'creates the queue with trip length 10' do
        make_command(params).call
        expect(user_game.explore_queues.last.turn).to eq(10)
      end

      it 'uses quantity * 2 horses' do
        original_horses = user_game.horses
        make_command(params).call
        user_game.reload
        expect(user_game.horses).to eq(original_horses - 10)
      end
    end

    context 'with horse_setting: three_horses' do
      before { user_game.update!(horses: 100) }

      let(:params) { valid_params.merge(horse_setting: 'three_horses') }

      it 'creates the queue with trip length 12' do
        make_command(params).call
        expect(user_game.explore_queues.last.turn).to eq(12)
      end

      it 'uses quantity * 3 horses' do
        original_horses = user_game.horses
        make_command(params).call
        user_game.reload
        expect(user_game.horses).to eq(original_horses - 15)
      end
    end

    context 'when quantity equals available people' do
      # user_game.people <= quantity triggers error (strict greater-than check)
      it 'adds an error when quantity >= people' do
        user_game.update!(people: 5)
        command = make_command(valid_params)
        command.call
        expect(command.errors).to include("You don't have that many people.")
      end
    end

    context 'when not enough people' do
      before { user_game.update!(people: 3) }

      it 'adds an error' do
        command = make_command(valid_params)
        command.call
        expect(command.errors).to include("You don't have that many people.")
      end

      it 'does not create an explore queue' do
        expect { make_command(valid_params).call }
          .not_to change { user_game.explore_queues.count }
      end
    end

    context 'when not enough horses for the horse_setting' do
      before { user_game.update!(horses: 0) }

      let(:params) { valid_params.merge(horse_setting: 'one_horse') }

      it 'adds an error' do
        command = make_command(params)
        command.call
        expect(command.errors.first).to include('enough horses')
      end

      it 'does not create an explore queue' do
        expect { make_command(params).call }
          .not_to change { user_game.explore_queues.count }
      end
    end

    context 'when not enough food' do
      before { user_game.update!(food: 0) }

      it 'adds an error' do
        command = make_command(valid_params)
        command.call
        expect(command.errors).to include("You don't have that much food.")
      end

      it 'does not create an explore queue' do
        expect { make_command(valid_params).call }
          .not_to change { user_game.explore_queues.count }
      end
    end

    context 'when max explorers would be exceeded' do
      before do
        # town_center: 10, max_explorers_per: 6 → max 60
        # fill up 58 existing explorers (turn > 0)
        user_game.explore_queues.create!(
          people: 58,
          horse_setting: :without_horses,
          seek_land: :all_land,
          food: 100,
          horses: 0,
          turn: 6,
          turns_used: 0
        )
      end

      it 'adds an error when total would exceed max' do
        # 58 existing + 5 new = 63 > 60
        command = make_command(valid_params)
        command.call
        expect(command.errors.first).to match(/total of \d+ explorers/i)
      end

      it 'does not create an explore queue' do
        expect { make_command(valid_params).call }
          .not_to change { user_game.explore_queues.count }
      end

      it 'allows adding exactly up to the max' do
        # Reduce existing explorers so we can add 4 (model minimum) and still hit 60
        # Change setup: 56 existing + 4 new = 60 ≤ 60
        user_game.explore_queues.last.update_columns(people: 56)
        command = make_command(valid_params.merge(quantity: '4'))
        command.call
        expect(command.errors).to be_empty
      end
    end

    context 'with multiple validation failures' do
      before do
        user_game.update!(people: 1, food: 0)
      end

      it 'collects all errors' do
        command = make_command(valid_params)
        command.call
        expect(command.errors.size).to be >= 2
      end
    end
  end
end
