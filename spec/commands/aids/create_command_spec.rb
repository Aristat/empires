# frozen_string_literal: true

RSpec.describe Aids::CreateCommand do
  let(:game)         { create(:game) }
  let(:sender_user)  { create(:user) }
  let(:vikings)      { Civilization.find_by!(key: 'vikings') }
  let(:user_game) do
    UserGames::CreateCommand.new(current_user: sender_user, game: game, civilization: vikings).call
  end

  describe '#call — self-send validation' do
    context 'when to_user_game_id is the same as the sender' do
      it 'fails with cannot_send_to_self error' do
        cmd = described_class.new(
          user_game: user_game,
          aid_params: { to_user_game_id: user_game.id }
        )
        cmd.call

        expect(cmd.failed?).to be true
        expect(cmd.errors).to include(I18n.t('aids.errors.cannot_send_to_self'))
      end
    end
  end
end
