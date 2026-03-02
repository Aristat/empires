# frozen_string_literal: true

module Games
  class PrepareScoresCommand
    def initialize(game:, current_user_game: nil)
      @game = game
      @current_user_game = current_user_game
    end

    def call
      user_games = @game.user_games.includes(:user, :civilization).order(score: :desc, id: :asc)

      players = user_games.each_with_index.map do |user_game, index|
        research_levels = UserGame::RESEARCHES.keys.sum { |key| user_game.send("#{key}_researches").to_i }

        {
          rank: index + 1,
          id: user_game.id,
          email: user_game.user.email,
          civilization: user_game.civilization.name,
          score: user_game.score,
          total_land: user_game.m_land + user_game.f_land + user_game.p_land,
          research_levels: research_levels,
          online: user_game.updated_at >= 10.minutes.ago
        }
      end

      {
        total_players: players.size,
        online_players: players.count { |p| p[:online] },
        current_user_game_id: @current_user_game&.id,
        players: players
      }
    end
  end
end
