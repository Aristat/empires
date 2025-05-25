# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: train_queues
#
#  id              :bigint           not null, primary key
#  quantity        :integer          not null
#  soldier_key     :integer          not null
#  turns_remaining :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_game_id    :bigint           not null
#
# Indexes
#
#  index_train_queues_on_user_game_id  (user_game_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_game_id => user_games.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class TrainQueue < ApplicationRecord
  belongs_to :user_game

  enum :soldier_key, {
    unique_unit: 0,
    archer: 1,
    swordsman: 2,
    horseman: 3,
    catapult: 4,
    macemen: 5,
    trained_peasant: 6,
    thieve: 7
  }, prefix: true
end
