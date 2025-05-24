module UserGames
  class EfficiencyOfExploreCommand
    attr_reader :total_land

    def initialize(total_land:)
      @total_land = total_land
    end

    def call
      return 100 if total_land <= 500_000

      mult = total_land / 500_000.0
      mult = 99 if mult >= 100
      (100 - mult).round(2)
    end
  end
end
