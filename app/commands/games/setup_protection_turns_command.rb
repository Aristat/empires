# frozen_string_literal: true

module Games
  class SetupProtectionTurnsCommand < BaseCommand
    DEFAULT_PROTECTION_TURNS = 200

    attr_reader :user_game

    def initialize(user_game:)
      super()
      @user_game = user_game
    end

    def call
      turns = user_game.game.settings['protection_turns'].to_i
      turns = DEFAULT_PROTECTION_TURNS if turns <= 0

      user_game.protection_turns = turns
      user_game.save!

      self
    end
  end
end
