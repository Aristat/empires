# frozen_string_literal: true

module Games
  class PrepareScoresCommand < BaseCommand
    ONLINE_THRESHOLD = 10.minutes

    attr_reader :scores_data

    def initialize(game:, current_user_game: nil)
      super()
      @game = game
      @current_user_game = current_user_game
    end

    def call
      build_scores_data
      self
    end

    private

    def build_scores_data
      players = []
      online_players = 0

      @game.user_games.includes(:user, :civilization).order(score: :desc, id: :asc).each_with_index do |user_game, index|
        online = user_game.updated_at >= ONLINE_THRESHOLD.ago
        online_players += 1 if online

        research_levels = UserGame::RESEARCHES.keys.sum { user_game.send("#{_1}_researches").to_i }

        players << {
          rank: index + 1,
          id: user_game.id,
          email: user_game.user.email,
          civilization: user_game.civilization.name,
          score: user_game.score,
          total_land: user_game.m_land + user_game.f_land + user_game.p_land,
          research_levels: research_levels,
          online: online,
          under_protection: user_game.protection_turns > 0,
          protection_turns_remaining: user_game.protection_turns
        }
      end

      @scores_data = {
        total_players: players.length,
        online_players: online_players,
        current_user_game_id: @current_user_game&.id,
        players: players
      }
    end
  end
end
