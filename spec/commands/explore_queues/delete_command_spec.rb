# frozen_string_literal: true

RSpec.describe ExploreQueues::DeleteCommand do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:civilization) { Civilization.find_by!(key: 'vikings') }
  let(:user_game) do
    UserGames::CreateCommand.new(current_user: user, game: game, civilization: civilization).call
  end

  def create_explore_queue(**attrs)
    user_game.explore_queues.create!(
      {
        people: 5,
        horse_setting: :without_horses,
        seek_land: :all_land,
        food: 50,
        horses: 0,
        turn: 6,
        turns_used: 0
      }.merge(attrs)
    )
  end

  describe '#call' do
    context 'with a cancelable queue (turns_used: 0, created recently)' do
      let!(:queue) { create_explore_queue(food: 50, horses: 0, people: 5) }

      it 'has no errors' do
        command = described_class.new(user_game: user_game, explore_queues: [queue])
        command.call
        expect(command.errors).to be_empty
      end

      it 'destroys the explore queue' do
        described_class.new(user_game: user_game, explore_queues: [queue]).call
        expect(ExploreQueue.exists?(queue.id)).to be false
      end

      it 'refunds food, horses, and people to user_game' do
        original_food = user_game.food
        original_horses = user_game.horses
        original_people = user_game.people

        described_class.new(user_game: user_game, explore_queues: [queue]).call
        user_game.reload

        expect(user_game.food).to eq(original_food + 50)
        expect(user_game.horses).to eq(original_horses)
        expect(user_game.people).to eq(original_people + 5)
      end
    end

    context 'with a queue that has been partially used (turns_used > 0)' do
      let!(:queue) { create_explore_queue(turns_used: 2) }

      it 'does not destroy the queue' do
        described_class.new(user_game: user_game, explore_queues: [queue]).call
        expect(ExploreQueue.exists?(queue.id)).to be true
      end

      it 'does not refund resources' do
        original_food = user_game.food
        described_class.new(user_game: user_game, explore_queues: [queue]).call
        user_game.reload
        expect(user_game.food).to eq(original_food)
      end
    end

    context 'with a queue created more than 15 minutes ago' do
      let!(:queue) { create_explore_queue }

      before { queue.update_columns(created_at: 20.minutes.ago) }

      it 'does not destroy the queue' do
        described_class.new(user_game: user_game, explore_queues: [queue]).call
        expect(ExploreQueue.exists?(queue.id)).to be true
      end

      it 'does not refund resources' do
        original_food = user_game.food
        described_class.new(user_game: user_game, explore_queues: [queue]).call
        user_game.reload
        expect(user_game.food).to eq(original_food)
      end
    end

    context 'with mixed cancelable and non-cancelable queues' do
      let!(:cancelable_queue) { create_explore_queue(food: 30, horses: 0, people: 4) }
      let!(:used_queue) { create_explore_queue(food: 20, horses: 0, people: 4, turns_used: 1) }

      it 'only destroys the cancelable queue' do
        described_class.new(user_game: user_game, explore_queues: [cancelable_queue, used_queue]).call
        expect(ExploreQueue.exists?(cancelable_queue.id)).to be false
        expect(ExploreQueue.exists?(used_queue.id)).to be true
      end

      it 'only refunds resources for the cancelable queue' do
        original_food = user_game.food
        described_class.new(user_game: user_game, explore_queues: [cancelable_queue, used_queue]).call
        user_game.reload
        expect(user_game.food).to eq(original_food + 30)
      end
    end

    context 'with a queue that uses horses' do
      let!(:queue) { create_explore_queue(food: 40, horses: 5, people: 5, horse_setting: :one_horse) }

      it 'refunds horses along with food and people' do
        original_horses = user_game.horses
        described_class.new(user_game: user_game, explore_queues: [queue]).call
        user_game.reload
        expect(user_game.horses).to eq(original_horses + 5)
      end
    end

    context 'with an empty list' do
      it 'has no errors and does not change user_game' do
        original_food = user_game.food
        command = described_class.new(user_game: user_game, explore_queues: [])
        command.call
        user_game.reload
        expect(command.errors).to be_empty
        expect(user_game.food).to eq(original_food)
      end
    end
  end
end
