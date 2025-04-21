module UserGames
  class UpdateScoreCommand
    attr_reader :user_game

    def initialize(user_game:)
      @user_game = user_game
    end

    def call
      total_buildings = user_game.wood_cutter + user_game.hunter + user_game.farm + user_game.gold_mine * 2 +
                        user_game.tool_maker + user_game.iron_mine + (user_game.town_center * 10) +
                        user_game.market + user_game.house + user_game.stable + (user_game.mage_tower * 3) +
                        user_game.weaponsmith + user_game.fort + (user_game.tower * 5) + user_game.winery +
                        user_game.warehouse

      land_score = (user_game.f_land * 4) + (user_game.m_land * 5) + (user_game.p_land * 3)
      resources_score = (user_game.food * 0.0005).round + (user_game.wood * 0.005).round + (user_game.iron * 0.005) +
                    (user_game.gold * 0.00001).round + (user_game.tools * 0.01).round +
                    (user_game.horses * 0.015).round + (user_game.wine * 0.005).round

      total_score = total_buildings + land_score + resources_score
      user_game.update!(score: total_score)
    end
  end
end
