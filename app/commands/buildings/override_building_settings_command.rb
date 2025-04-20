module Buildings
  class OverrideBuildingSettingsCommand
    def initialize(building:, civilization:)
      @building = building
      @civilization = civilization
    end

    def call
      base_settings = @building.settings
      civ_overrides = @civilization.settings.dig('buildings', @building.key) || {}
      
      # Merge settings with civilization overrides taking precedence
      base_settings.merge(civ_overrides)
    end
  end
end 