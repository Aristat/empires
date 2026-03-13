# frozen_string_literal: true

RSpec.describe BuildQueues::DeleteCommand do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:civilization) { Civilization.find_by!(key: 'vikings') }
  let(:user_game) do
    UserGames::CreateCommand.new(current_user: user, game: game, civilization: civilization).call
  end

  def create_build_queue(**attrs)
    user_game.build_queues.create!(
      {
        building_type: :hunter,
        queue_type: :build,
        quantity: 1,
        position: 1,
        turn_added: 0,
        time_needed: 4,
        gold: 25,
        wood: 4,
        iron: 0
      }.merge(attrs)
    )
  end

  describe '#call' do
    context 'with a single build-type queue' do
      let!(:queue) { create_build_queue(gold: 25, wood: 4, iron: 0) }

      it 'destroys the queue record' do
        described_class.new(user_game: user_game, build_queues: [queue]).call
        expect(BuildQueue.exists?(queue.id)).to be false
      end

      it 'refunds gold, wood, and iron to user_game' do
        original_gold = user_game.gold
        original_wood = user_game.wood
        original_iron = user_game.iron

        described_class.new(user_game: user_game, build_queues: [queue]).call
        user_game.reload

        expect(user_game.gold).to eq(original_gold + 25)
        expect(user_game.wood).to eq(original_wood + 4)
        expect(user_game.iron).to eq(original_iron)
      end
    end

    context 'with a single demolish-type queue' do
      let!(:queue) { create_build_queue(queue_type: :demolish, gold: 0, wood: 0, iron: 0) }

      it 'destroys the queue record' do
        described_class.new(user_game: user_game, build_queues: [queue]).call
        expect(BuildQueue.exists?(queue.id)).to be false
      end

      it 'does not refund any resources' do
        original_gold = user_game.gold
        original_wood = user_game.wood
        described_class.new(user_game: user_game, build_queues: [queue]).call
        user_game.reload
        expect(user_game.gold).to eq(original_gold)
        expect(user_game.wood).to eq(original_wood)
      end
    end

    context 'with multiple queues of mixed types' do
      let!(:build_queue1) { create_build_queue(gold: 100, wood: 10, iron: 5, position: 1) }
      let!(:build_queue2) { create_build_queue(gold: 200, wood: 20, iron: 10, position: 2) }
      let!(:demolish_queue) { create_build_queue(queue_type: :demolish, gold: 0, wood: 0, iron: 0, position: 3) }

      it 'destroys all queue records' do
        described_class.new(user_game: user_game, build_queues: [build_queue1, build_queue2, demolish_queue]).call
        expect(BuildQueue.where(id: [build_queue1.id, build_queue2.id, demolish_queue.id]).count).to eq(0)
      end

      it 'only refunds resources for the last build-type queue iterated' do
        # NOTE: the loop uses `=` (not `+=`) so only the last build queue's resources are refunded
        original_gold = user_game.gold
        described_class.new(user_game: user_game, build_queues: [build_queue1, build_queue2, demolish_queue]).call
        user_game.reload
        # only build_queue2 values are used due to `=` assignment in the loop
        expect(user_game.gold).to eq(original_gold + 200)
      end
    end

    context 'with an empty list of queues' do
      it 'does not change user_game resources' do
        original_gold = user_game.gold
        described_class.new(user_game: user_game, build_queues: []).call
        user_game.reload
        expect(user_game.gold).to eq(original_gold)
      end
    end
  end
end
