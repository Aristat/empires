class PrepareBuildingsDataCommand < BaseCommand
  attr_reader :civilization

  def initialize(civilization:)
    @civilization = civilization
  end

  def call
    Building.all.map do |building|
      base_settings = building.settings
      civ_overrides = civilization.settings.dig("buildings", building.key) || {}
      settings = base_settings.merge(civ_overrides)

      {
        id: building.id,
        name: building.name,
        key: building.key,
        land_type: settings["land"],
        production_name: settings["production_name"],
        allow_off: settings["allow_off"]
      }
    end
  end
end
