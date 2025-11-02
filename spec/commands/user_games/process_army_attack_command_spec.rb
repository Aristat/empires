# frozen_string_literal: true

RSpec.describe UserGames::ProcessArmyAttackCommand do
  subject { command.call }

  let(:from_user) { create(:user) }
  let(:to_user) { create(:user) }
  let(:game) { create(:game) }
  let(:vikings_civilization) { Civilization.find_by!(key: 'vikings') }
  let(:chinese_civilization) { Civilization.find_by!(key: 'chinese') }
  let(:attacker_user_game) do
    UserGames::CreateCommand.new(current_user: from_user, game: game, civilization: vikings_civilization).call
  end
  let(:defender_user_game) do
    UserGames::CreateCommand.new(current_user: to_user, game: game, civilization: chinese_civilization).call
  end
  let(:attack_queue) do
    create(:attack_queue, game: game, user_game: attacker_user_game, to_user_game: defender_user_game,
           attack_status: :done_fighting, attack_type: attack_type, swordsman_soldiers: 1500)
  end
  let(:command) do
    described_class.new(
      user_game: attacker_user_game,
      data: PrepareDataCommand.new(user_game: attacker_user_game).call,
      attack_queue: attack_queue,
    )
  end
  let(:attack_type) { :army_conquer }

  describe '#execute' do
    it 'returns attack log' do
      result = subject

      expect(result[:attacker_wins]).to be_truthy
      expect(result[:attack_log]).to be_present
      expect(command.errors).to be_blank
    end
  end
end
