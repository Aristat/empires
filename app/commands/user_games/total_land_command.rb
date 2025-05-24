module UserGames
  class TotalLandCommand
    attr_reader :user_game

    def initialize(user_game:)
      @user_game = user_game
    end

    def call
      user_game.m_land + user_game.f_land + user_game.p_land
    end
  end
end
