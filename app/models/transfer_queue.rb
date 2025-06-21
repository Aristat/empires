# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: transfer_queues
#
#  id              :bigint           not null, primary key
#  bows            :integer
#  bows_price      :integer
#  food            :integer
#  food_price      :integer
#  gold            :integer
#  horses          :integer
#  horses_price    :integer
#  iron            :integer
#  iron_price      :integer
#  maces           :integer
#  maces_price     :integer
#  swords          :integer
#  swords_price    :integer
#  tools           :integer
#  tools_price     :integer
#  transfer_type   :integer          not null
#  turns_remaining :integer          not null
#  wood            :integer
#  wood_price      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  game_id         :bigint           not null
#  to_user_game_id :bigint
#  user_game_id    :bigint           not null
#
# Indexes
#
#  index_transfer_queues_on_game_id          (game_id)
#  index_transfer_queues_on_to_user_game_id  (to_user_game_id)
#  index_transfer_queues_on_user_game_id     (user_game_id)
#
# Foreign Keys
#
#  fk_rails_...  (to_user_game_id => user_games.id)
#  fk_rails_...  (user_game_id => user_games.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class TransferQueue < ApplicationRecord
  # TODO! add sell wine
  RESOURCES = [
    :wood,
    :food,
    :iron,
    :swords,
    :maces,
    :bows,
    :tools,
    :horses
  ].freeze

  belongs_to :game
  belongs_to :user_game
  belongs_to :to_user_game, class_name: 'UserGame', optional: true

  enum :transfer_type, {
    sell: 0,
    aid: 1,
    buy: 2
  }, prefix: true
end
