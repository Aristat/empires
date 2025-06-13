module Games
  class CreateFakeUsersCommand < BaseCommand
    attr_reader :game

    def initialize(game:)
      @game = game
    end

    def call
      2.times do |i|
        user = User.find_or_initialize_by(
          email: "test_fake_user_#{i}@gmail.com"
        )
        unless user.persisted?
          user.name = "Test fake user #{i}"
          user.password = '123456'
          user.password_confirmation = '123456'
          user.save!
        end


        civilization = game.civilizations.sample
        user_game = UserGames::CreateCommand.new(
          current_user: user,
          game: game,
          civilization: civilization
        ).call

        TransferQueue.create!(
          game: game, user_game: user_game, turns_remaining: 1, transfer_type: :sell,
          food: 5000, food_price: 20, wood: 5000, wood_price: 30
        )

        TransferQueue.create!(
          game: game, user_game: user_game, turns_remaining: 0, transfer_type: :sell,
          food: 7000, food_price: 20
        )

        TransferQueue.create!(
          game: game, user_game: user_game, turns_remaining: 0, transfer_type: :sell,
          iron: 400, iron_price: 100, wood: 300, wood_price: 30
        )
      end
    end
  end
end
