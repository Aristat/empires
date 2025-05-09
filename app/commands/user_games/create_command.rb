module UserGames
  class CreateCommand
    attr_reader :current_user, :game, :civilization

    def initialize(current_user:, game:, civilization:)
      @current_user = current_user
      @game = game
      @civilization = civilization
    end

    def call
      user_game = current_user.user_games.create!(
        game: game,
        civilization: civilization,
        food_ratio: 1,
        tool_maker: 10,
        wood_cutter: 20,
        gold_mine: 10,
        hunter: 50,
        tower: 10,
        town_center: 10,
        market: 10,
        iron_mine: 20,
        house: 50,
        farm: 20,
        f_land: 1000,
        m_land: 500,
        p_land: 2500,
        people: 3000,
        wood: 1000,
        food: 2500,
        iron: 1000,
        gold: 100000,
        tools: 250,
        wall_build_per_turn: 0,
        last_turn_at: Time.current,
        current_turns: game.start_turns
      )

      UserGames::UpdateScoreCommand.new(user_game: user_game).call

      user_game
    end
  end
end
