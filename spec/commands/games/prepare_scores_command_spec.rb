# frozen_string_literal: true

RSpec.describe Games::PrepareScoresCommand do
  let(:game) { create(:game) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  let!(:user_game1) do
    create(:user_game, user: user1, game: game, civilization: game.civilizations.first, score: 999_999)
  end
  let!(:user_game2) do
    create(:user_game, user: user2, game: game, civilization: game.civilizations.second, score: 500_000)
  end

  let(:total_players) { game.user_games.count }

  # Make all user_games offline by default so tests start from a clean state
  before { game.user_games.update_all(updated_at: 20.minutes.ago) }

  describe '#call' do
    subject(:cmd) { described_class.new(game: game, current_user_game: user_game1).call }

    it 'succeeds' do
      expect(cmd.success?).to be true
    end

    it 'returns total_players matching all user_games in the game' do
      expect(cmd.scores_data[:total_players]).to eq(total_players)
    end

    it 'places user_game1 (highest score) first' do
      expect(cmd.scores_data[:players].first[:id]).to eq(user_game1.id)
    end

    it 'places user_game2 (second highest score) before lower-scored players' do
      ids = cmd.scores_data[:players].map { |p| p[:id] }
      expect(ids.index(user_game1.id)).to be < ids.index(user_game2.id)
    end

    it 'assigns rank 1 to the top player' do
      expect(cmd.scores_data[:players].first[:rank]).to eq(1)
    end

    it 'assigns sequential ranks' do
      ranks = cmd.scores_data[:players].map { |p| p[:rank] }
      expect(ranks).to eq((1..total_players).to_a)
    end

    it 'sets current_user_game_id from the passed user_game' do
      expect(cmd.scores_data[:current_user_game_id]).to eq(user_game1.id)
    end

    it 'includes all required keys per player' do
      player = cmd.scores_data[:players].find { |p| p[:id] == user_game1.id }
      expect(player).to include(:rank, :id, :email, :civilization, :score, :total_land, :research_levels, :online,
                                 :under_protection, :protection_turns_remaining)
    end

    it 'includes correct email' do
      player = cmd.scores_data[:players].find { |p| p[:id] == user_game1.id }
      expect(player[:email]).to eq(user1.email)
    end

    it 'includes correct score' do
      player = cmd.scores_data[:players].find { |p| p[:id] == user_game1.id }
      expect(player[:score]).to eq(999_999)
    end

    it 'calculates total_land as sum of m_land, f_land, p_land' do
      player = cmd.scores_data[:players].find { |p| p[:id] == user_game1.id }
      expected = user_game1.m_land + user_game1.f_land + user_game1.p_land
      expect(player[:total_land]).to eq(expected)
    end

    context 'when no current_user_game is passed (spectator)' do
      subject(:cmd) { described_class.new(game: game).call }

      it 'sets current_user_game_id to nil' do
        expect(cmd.scores_data[:current_user_game_id]).to be_nil
      end
    end

    context 'online status' do
      it 'marks a recently active player as online' do
        user_game1.update!(updated_at: 5.minutes.ago)
        player = cmd.scores_data[:players].find { |p| p[:id] == user_game1.id }
        expect(player[:online]).to be true
      end

      it 'marks a stale player as offline' do
        # before block already set all to 20 min ago
        player = cmd.scores_data[:players].find { |p| p[:id] == user_game1.id }
        expect(player[:online]).to be false
      end

      it 'counts only online players' do
        user_game1.update!(updated_at: 5.minutes.ago)
        # all others remain 20 min ago
        expect(cmd.scores_data[:online_players]).to eq(1)
      end
    end

    context 'protection turns' do
      it 'reports under_protection true when protection_turns > 0' do
        user_game2.update!(protection_turns: 50)
        player = cmd.scores_data[:players].find { |p| p[:id] == user_game2.id }
        expect(player[:under_protection]).to be true
        expect(player[:protection_turns_remaining]).to eq(50)
      end

      it 'reports under_protection false when protection_turns is 0' do
        user_game1.update!(protection_turns: 0)
        player = cmd.scores_data[:players].find { |p| p[:id] == user_game1.id }
        expect(player[:under_protection]).to be false
      end
    end

    context 'tie-breaking' do
      before { user_game2.update!(score: user_game1.score) }

      it 'breaks ties by id ascending' do
        ids_in_result = cmd.scores_data[:players].map { |p| p[:id] }
        tied_positions = [ids_in_result.index(user_game1.id), ids_in_result.index(user_game2.id)]
        lower_id = [user_game1.id, user_game2.id].min
        lower_id_position = ids_in_result.index(lower_id)
        expect(lower_id_position).to be < tied_positions.max
      end
    end

    context 'research levels' do
      it 'sums all research columns' do
        user_game1.update!(researches: UserGame::RESEARCHES.transform_values { '2' })
        expected = UserGame::RESEARCHES.keys.length * 2
        player = cmd.scores_data[:players].find { |p| p[:id] == user_game1.id }
        expect(player[:research_levels]).to eq(expected)
      end
    end
  end
end
