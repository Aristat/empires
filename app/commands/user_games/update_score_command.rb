module UserGames
  class UpdateScoreCommand
    # Building score weights — premium buildings count for more points
    BUILDING_SCORE_GOLD_MINE     = 2
    BUILDING_SCORE_TOWN_CENTER   = 10
    BUILDING_SCORE_MAGE_TOWER    = 3
    BUILDING_SCORE_TOWER         = 5

    # Land score weights — mountain land is most valuable, plains least
    LAND_SCORE_FOREST   = 4
    LAND_SCORE_MOUNTAIN = 5
    LAND_SCORE_PLAIN    = 3

    # Resource score weights — rarer resources contribute more score per unit
    RESOURCE_SCORE_FOOD    = 0.0005
    RESOURCE_SCORE_WOOD    = 0.005
    RESOURCE_SCORE_IRON    = 0.005
    RESOURCE_SCORE_GOLD    = 0.00001
    RESOURCE_SCORE_TOOLS   = 0.01
    RESOURCE_SCORE_HORSES  = 0.015
    RESOURCE_SCORE_WINE    = 0.005

    attr_reader :user_game

    def initialize(user_game:)
      @user_game = user_game
    end

    def call
      total_buildings = user_game.wood_cutter + user_game.hunter + user_game.farm + user_game.gold_mine * BUILDING_SCORE_GOLD_MINE +
                        user_game.tool_maker + user_game.iron_mine + (user_game.town_center * BUILDING_SCORE_TOWN_CENTER) +
                        user_game.market + user_game.house + user_game.stable + (user_game.mage_tower * BUILDING_SCORE_MAGE_TOWER) +
                        user_game.weaponsmith + user_game.fort + (user_game.tower * BUILDING_SCORE_TOWER) + user_game.winery +
                        user_game.warehouse

      land_score = (user_game.f_land * LAND_SCORE_FOREST) + (user_game.m_land * LAND_SCORE_MOUNTAIN) + (user_game.p_land * LAND_SCORE_PLAIN)
      resources_score = (user_game.food * RESOURCE_SCORE_FOOD).round + (user_game.wood * RESOURCE_SCORE_WOOD).round + (user_game.iron * RESOURCE_SCORE_IRON) +
                    (user_game.gold * RESOURCE_SCORE_GOLD).round + (user_game.tools * RESOURCE_SCORE_TOOLS).round +
                    (user_game.horses * RESOURCE_SCORE_HORSES).round + (user_game.wine * RESOURCE_SCORE_WINE).round

      total_score = total_buildings + land_score + resources_score
      user_game.update!(score: total_score)
    end
  end
end
