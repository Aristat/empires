# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# == Schema Information
#
# Table name: games
#
#  id               :bigint           not null, primary key
#  max_turns        :integer
#  name             :string
#  seconds_per_turn :integer
#  settings         :jsonb            not null
#  start_turns      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
class Game < ApplicationRecord
  has_many :user_games, dependent: :destroy
  has_many :users, through: :user_games

  has_many :civilizations, dependent: :destroy
  has_many :buildings, dependent: :destroy
  has_many :soldiers, dependent: :destroy

  store_accessor :settings,
                 :local_wood_sell_price, :local_wood_buy_price,
                 :local_food_sell_price, :local_food_buy_price,
                 :local_iron_sell_price, :local_iron_buy_price,
                 :local_tools_sell_price, :local_tools_buy_price,
                 :people_eat_one_food, :extra_food_per_land,
                 :people_burn_one_wood, :pop_increase_modifier,
                 :wall_use_gold, :wall_use_iron,
                 :wall_use_wood, :wall_use_wine,
                 :global_fee_percent, :global_wood_min_price, :global_wood_max_price, :global_food_min_price,
                 :global_food_max_price, :global_iron_min_price, :global_iron_max_price, :global_tools_min_price,
                 :global_tools_max_price, :global_bows_min_price, :global_bows_max_price, :global_swords_min_price,
                 :global_swords_max_price, :global_maces_min_price, :global_maces_max_price, :global_horses_min_price,
                 :global_horses_max_price

  validates :name, presence: true
end
