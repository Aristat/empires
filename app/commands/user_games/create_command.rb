module UserGames
  class CreateCommand
    attr_reader :current_user, :game, :civilization

    def initialize(current_user:, game:, civilization:)
      @current_user = current_user
      @game = game
      @civilization = civilization
    end

    def call
      current_user.user_games.create!(
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
        weaponsmith: 0,
        fort: 0,
        warehouse: 0,
        stable: 0,
        mage_tower: 0,
        winery: 0,
        f_land: 1000,
        m_land: 500,
        p_land: 2500,
        swordsman: 0,
        archers: 0,
        horseman: 0,
        people: 3000,
        wood: 1000,
        food: 2500,
        iron: 1000,
        gold: 100000,
        tools: 250,
        wine: 0,
        turn: 0,
        last_turn_at: Time.current,
        current_turns: game.start_turns
      )
    end
  end
end

