# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: attack_queues
#
#  id              :bigint           not null, primary key
#  attack_status   :integer          not null
#  attack_type     :integer          not null
#  cost_food       :integer
#  cost_gold       :integer
#  cost_iron       :integer
#  cost_wine       :integer
#  cost_wood       :integer
#  soldiers        :jsonb            not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  game_id         :bigint           not null
#  to_user_game_id :bigint
#  user_game_id    :bigint           not null
#
# Indexes
#
#  index_attack_queues_on_game_id          (game_id)
#  index_attack_queues_on_to_user_game_id  (to_user_game_id)
#  index_attack_queues_on_user_game_id     (user_game_id)
#
# Foreign Keys
#
#  fk_rails_...  (to_user_game_id => user_games.id)
#  fk_rails_...  (user_game_id => user_games.id)
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
FactoryBot.define do
  factory :attack_queue do
    game
  end
end
