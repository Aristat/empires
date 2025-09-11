# frozen_string_literal: true

RSpec.describe UserGames::EndTurnCommand do
  subject { command.call }

  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:civilization) { Civilization.find_by!(key: 'vikings') }
  let(:user_game) { UserGames::CreateCommand.new(current_user: user, game: game, civilization: civilization).call }
  let(:command) { described_class.new(user_game: user_game) }

  describe '#execute' do
    it 'ends turn data' do
      result = subject

      expect(result).to be_truthy
      expect(command.errors).to be_blank
    end
  end
end
