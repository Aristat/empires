# frozen_string_literal: true

RSpec.describe UserGames::ProcessThiefAttackCommand do
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
           attack_status: :done_fighting, attack_type: attack_type, thieve_soldiers: 100)
  end
  let(:command) do
    described_class.new(
      user_game: attacker_user_game,
      data: PrepareDataCommand.new(user_game: attacker_user_game).call,
      attack_queue: attack_queue,
    )
  end
  let(:attack_type) { :thief_steal_army_information }

  describe '#execute' do
    it 'returns attack log' do
      result = subject

      expect(result[:attacker_wins]).to be_truthy
      expect(result[:attack_log]).to be_present
      expect(command.errors).to be_blank
    end

    context 'when lose the attack' do
      before do
        defender_user_game.update!(thieve_soldiers: 500)
      end

      it 'returns attack log' do
        result = subject

        expect(result[:attacker_wins]).to be_falsey
        expect(result[:attack_log]).to be_present
        expect(command.errors).to be_blank
      end
    end

    context 'when attack_type is thief_steal_army_information' do
      let(:attack_type) { :thief_steal_goods }

      it 'returns attack log' do
        result = subject

        expect(result[:attacker_wins]).to be_truthy
        expect(result[:attack_log]).to be_present
        expect(result[:stolen_resources]).to be_present
        expect(command.errors).to be_blank
      end
    end

    context 'when attack_type is thief_poison_water' do
      let(:attack_type) { :thief_poison_water }

      before do
        defender_user_game.update!(swordsman_soldiers: 100)
      end

      it 'returns attack log' do
        result = subject

        expect(result[:attacker_wins]).to be_truthy
        expect(result[:attack_log]).to be_present
        expect(result[:stolen_resources]).to be_blank
        expect(command.errors).to be_blank

        defender_user_game.reload
        expect(defender_user_game.swordsman_soldiers < 100).to be_truthy
      end
    end

    context 'when attack_type is thief_set_fire' do
      let(:attack_type) { :thief_set_fire }

      it 'returns attack log' do
        result = subject

        expect(result[:attacker_wins]).to be_truthy
        expect(result[:attack_log]).to be_present
        expect(result[:stolen_resources]).to be_blank
        expect(command.errors).to be_blank
      end
    end
  end
end
