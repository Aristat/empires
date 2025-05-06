module BuildQueues
  class CreateCommand < BaseCommand
    attr_reader :user_game, :build_queue_params

    def initialize(user_game:, build_queue_params:)
      @user_game = user_game
      @build_queue_params = build_queue_params
    end

    def call
      p 'build_queue_params', build_queue_params
    end
  end
end
