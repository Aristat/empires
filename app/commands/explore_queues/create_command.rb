# frozen_string_literal: true

module ExploreQueues
  class CreateCommand < BaseCommand
    attr_reader :user_game, :params

    def initialize(user_game:, explore_queue_params:)
      @user_game = user_game
      @params = explore_queue_params

      super()
    end

    def call
      @user_game.explore_queues.create!(
        people: params[:quantity],
        horse_setting: params[:horse_setting],
        seek_land: params[:seek_land],
        )
      # TODO! move last_horse_setting to local storage to avoid extra db call
      @user_game.update(last_horse_setting: params[:horse_setting])
    rescue StandardError => e
      @errors << e.message
    end
  end
end
