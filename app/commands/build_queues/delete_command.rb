module BuildQueues
  class DeleteCommand
    attr_reader :user_game, :build_queues

    def initialize(user_game:, build_queues:)
      @user_game = user_game
      @build_queues = build_queues
    end

    def call
      increase_gold = 0
      increase_wood = 0
      increase_iron = 0

      build_queues.each do |build_queue|
        next unless build_queue.queue_type_build?

        increase_gold = build_queue.gold
        increase_wood = build_queue.wood
        increase_iron = build_queue.iron
      end

      user_game.update!(
        gold: user_game.gold + increase_gold,
        wood: user_game.wood + increase_wood,
        iron: user_game.iron + increase_iron
      )

      BuildQueue.where(id: build_queues.map(&:id)).destroy_all
    end
  end
end
