class UserGame < ApplicationRecord
    belongs_to :user
    belongs_to :game
    belongs_to :civilization

    has_many :build_queues, dependent: :destroy
end
