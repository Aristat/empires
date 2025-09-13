# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: civilizations
#
#  id          :bigint           not null, primary key
#  description :text
#  key         :string           not null
#  name        :string
#  settings    :jsonb            not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  game_id     :bigint           not null
#
# Indexes
#
#  index_civilizations_on_game_id          (game_id)
#  index_civilizations_on_game_id_and_key  (game_id,key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
FactoryBot.define do
  factory :civilization do
    game
    name { Faker::Lorem.characters }
    key { 'vikings' }
  end
end
