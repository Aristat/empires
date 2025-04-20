class Game < ApplicationRecord
  has_many :user_games, dependent: :destroy
  has_many :users, through: :user_games

  store_accessor :settings,
                 :local_wood_sell_price, :local_wood_buy_price,
                 :local_food_sell_price, :local_food_buy_price,
                 :local_iron_sell_price, :local_iron_buy_price,
                 :local_tools_sell_price, :local_tools_buy_price,
                 :people_eat_one_food, :extra_food_per_land,
                 :people_burn_one_wood, :pop_increase_modifier,
                 :wall_use_gold, :wall_use_iron,
                 :wall_use_wood, :wall_use_wine

  validates :name, presence: true
end
