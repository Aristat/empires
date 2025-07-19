# frozen_string_literal: true

module AttackQueues
  class CancelAttackCommand < BaseCommand
    attr_reader :user_game, :attack_queue

    def initialize(user_game:, attack_queue:)
      @user_game = user_game
      @attack_queue = attack_queue

      super()
    end

    def call
      validate_cancellation
      return if failed?

      if attack_queue.attack_status_preparing?
        return_resources_and_delete
      elsif attack_queue.attack_status_on_their_way? || attack_queue.attack_status_almost_there?
        set_returning_status
      else
        @errors << 'This attack cannot be cancelled at this stage'
      end
    end

    private

    def validate_cancellation
      unless attack_queue.can_cancel?
        @errors << 'This attack cannot be cancelled at this stage'
      end
    end

    def return_resources_and_delete
      UserGame::SOLDIERS.keys.each do |soldier_key|
        soldiers_count = attack_queue.send("#{soldier_key}_soldiers").to_i
        next if soldiers_count <= 0

        user_game.send("#{soldier_key}_soldiers=", user_game.send("#{soldier_key}_soldiers") + soldiers_count)
      end

      # Return all resources
      user_game.food += attack_queue.cost_food.to_i
      user_game.wine += attack_queue.cost_wine.to_i
      user_game.gold += attack_queue.cost_gold.to_i
      user_game.wood += attack_queue.cost_wood.to_i
      user_game.iron += attack_queue.cost_iron.to_i

      user_game.save!
      attack_queue.destroy!

      to_user_id = attack_queue.to_user_game_id
      to_user_name = attack_queue.to_user_game&.user&.email || to_user_id
      messages << "Your army stopped preparing to attack #{to_user_name} (#{to_user_id})."
    end

    def set_returning_status
      attack_queue.update!(attack_status: :returning)
      messages << 'Your army is returning to your empire as you requested and should be back soon.'
    end
  end
end
