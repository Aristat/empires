# frozen_string_literal: true

RSpec.describe AttackQueues::CreateArmyAttackCommand do
  let(:game)      { create(:game) }
  let(:attacker)  { create(:user) }
  let(:defender)  { create(:user) }
  let(:vikings)   { Civilization.find_by!(key: 'vikings') }
  let(:chinese)   { Civilization.find_by!(key: 'chinese') }
  let(:attacker_ug) do
    UserGames::CreateCommand.new(current_user: attacker, game: game, civilization: vikings).call
  end
  let(:defender_ug) do
    UserGames::CreateCommand.new(current_user: defender, game: game, civilization: chinese).call
  end

  let(:base_params) do
    {
      to_user_game_id: defender_ug.id,
      attack_type: 'army_conquer',
      send_all: false,
      maximum_wine: false,
      cost_wine: 0
    }
  end

  def build_command(params = {})
    described_class.new(user_game: attacker_ug, army_attack_params: base_params.merge(params))
  end

  before do
    attacker_ug.update!(
      swordsman_soldiers: 500,
      gold: 999_999,
      food: 999_999,
      wine: 0
    )
  end

  describe '#call — protection check' do
    context 'when the defender is under protection' do
      before { defender_ug.update!(protection_turns: 50) }

      it 'adds a protection error' do
        cmd = build_command(swordsman: 100)
        cmd.call
        expect(cmd.errors).not_to be_empty
      end

      it 'returns a protection error message mentioning turns remaining' do
        cmd = build_command(swordsman: 100)
        cmd.call
        expect(cmd.errors.first).to include('under protection for 50 more turns')
      end

      it 'does not create an attack queue' do
        cmd = build_command(swordsman: 100)
        expect { cmd.call }.not_to change(AttackQueue, :count)
      end
    end

    context 'when the defender has protection_turns of 0' do
      before { defender_ug.update!(protection_turns: 0) }

      it 'does not add a protection error' do
        cmd = build_command(swordsman: 100)
        cmd.call
        expect(cmd.errors).not_to include(match(/under protection/))
      end
    end

    context 'when trying to attack yourself (with protection expired)' do
      let(:self_params) { base_params.merge(to_user_game_id: attacker_ug.id, swordsman: 100) }

      before { attacker_ug.update!(protection_turns: 0) }

      it 'returns the self-attack error' do
        cmd = described_class.new(user_game: attacker_ug, army_attack_params: self_params)
        cmd.call
        expect(cmd.errors).to include('You cannot attack yourself')
      end
    end
  end
end
