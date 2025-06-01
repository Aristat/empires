# Buildings configurations based on civilization
class PrepareBuildingsDataCommand < BaseCommand
  attr_reader :game, :civilization

  def initialize(game:, civilization:)
    @game = game
    @civilization = civilization
  end

  def call
    Building.where(game_id: game.id).order(:position).each_with_object({}) do |building, result|
      base_settings = building.settings
      civ_overrides = civilization.settings.dig('buildings', building.key) || {}
      settings = base_settings.merge(civ_overrides)

      result[building.key] = {
        id: building.id,
        name: building.name,
        key: building.key,
        settings: settings
      }
    end
  end
end
