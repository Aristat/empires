# frozen_string_literal: true

RSpec.describe Games::SetupProtectionTurnsCommand do
  let(:user)  { create(:user) }
  let(:game)  { create(:game) }
  let(:civilization) { game.civilizations.first }
  let(:user_game) do
    UserGames::CreateCommand.new(current_user: user, game: game, civilization: civilization).call
  end

  describe '#call' do
    subject(:result) { described_class.new(user_game: user_game).call }

    context 'when game has protection_turns configured' do
      before { game.update!(settings: game.settings.merge('protection_turns' => 150)) }

      it 'succeeds' do
        expect(result.success?).to be true
      end

      it 'sets protection_turns on the user_game to the game setting' do
        result
        expect(user_game.reload.protection_turns).to eq(150)
      end
    end

    context 'when game has protection_turns set to 0' do
      before { game.update!(settings: game.settings.merge('protection_turns' => 0)) }

      it 'falls back to the default (200)' do
        result
        expect(user_game.reload.protection_turns).to eq(Games::SetupProtectionTurnsCommand::DEFAULT_PROTECTION_TURNS)
      end
    end

    context 'when game has no protection_turns key in settings' do
      before { game.update!(settings: game.settings.except('protection_turns')) }

      it 'falls back to the default (200)' do
        result
        expect(user_game.reload.protection_turns).to eq(Games::SetupProtectionTurnsCommand::DEFAULT_PROTECTION_TURNS)
      end
    end

    context 'when protection_turns is a large value' do
      before { game.update!(settings: game.settings.merge('protection_turns' => 1000)) }

      it 'sets the full value without capping' do
        result
        expect(user_game.reload.protection_turns).to eq(1000)
      end
    end
  end
end
