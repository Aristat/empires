module UserGames
  class EfficiencyOfExploreCommand
    # Below this land count, exploration is 100% efficient
    LARGE_LAND_THRESHOLD = 500_000
    # Cap the efficiency multiplier so it never reaches 0 (would divide by 100 to get %)
    EFFICIENCY_MULTIPLIER_CAP = 99

    attr_reader :total_land

    def initialize(total_land:)
      @total_land = total_land
    end

    def call
      return 100 if total_land <= LARGE_LAND_THRESHOLD

      # Efficiency decreases as land grows beyond threshold:
      # mult = land / threshold → (100 - mult) gives efficiency %
      # Capped so efficiency never reaches 0
      mult = total_land / LARGE_LAND_THRESHOLD.to_f
      mult = EFFICIENCY_MULTIPLIER_CAP if mult >= 100
      (100 - mult).round(2)
    end
  end
end
