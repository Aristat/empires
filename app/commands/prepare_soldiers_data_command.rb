# Soldiers configurations based on civilization
class PrepareSoldiersDataCommand < BaseCommand
  attr_reader :civilization

  def initialize(civilization:)
    @civilization = civilization
  end

  def call
    Soldier.order(:position).each_with_object({}) do |soldier, result|
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
