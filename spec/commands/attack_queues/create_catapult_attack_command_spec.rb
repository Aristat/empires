# frozen_string_literal: true

RSpec.describe AttackQueues::CreateCatapultAttackCommand do
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
      attack_type: 'catapult_army_and_towers',
      send_all: true
    }
  end

  def build_command(params = {})
    described_class.new(user_game: attacker_ug, catapult_attack_params: base_params.merge(params))
  end

  before do
    attacker_ug.update!(
      catapult_soldiers: 10,
      wood: 999_999,
      iron: 999_999
    )
  end

  describe '#call — protection check' do
    context 'when the defender is under protection' do
      before { defender_ug.update!(protection_turns: 99) }

      it 'adds a protection error' do
        cmd = build_command
        cmd.call
        expect(cmd.errors).not_to be_empty
      end

      it 'returns a protection error message mentioning turns remaining' do
        cmd = build_command
        cmd.call
        expect(cmd.errors.first).to include('under protection for 99 more turns')
      end

      it 'does not create an attack queue' do
        cmd = build_command
        expect { cmd.call }.not_to change(AttackQueue, :count)
      end
    end

    context 'when the defender has no protection' do
      before { defender_ug.update!(protection_turns: 0) }

      it 'does not add a protection error' do
        cmd = build_command
        cmd.call
        expect(cmd.errors).not_to include(match(/under protection/))
      end
    end
  end
end
