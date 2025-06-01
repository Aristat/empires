# Soldiers configurations based on civilization
class PrepareSoldiersDataCommand < BaseCommand
  attr_reader :game, :civilization

  def initialize(game:, civilization:)
    @game = game
    @civilization = civilization
  end

  def call
    Soldier.where(game_id: game.id).order(:position).each_with_object({}) do |soldier, result|
      base_settings = soldier.settings
      civ_overrides = civilization.settings.dig('soldiers', soldier.key) || {}
      settings = base_settings.merge(civ_overrides)

      result[soldier.key] = {
        id: soldier.id,
        name: soldier.name,
        key: soldier.key,
        position: soldier.position,
        settings: settings
      }
    end
  end
end
