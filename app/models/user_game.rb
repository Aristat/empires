class UserGame < ApplicationRecord
    belongs_to :user
    belongs_to :game
    belongs_to :civilization
end
  