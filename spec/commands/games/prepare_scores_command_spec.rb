# frozen_string_literal: true

RSpec.describe Games::PrepareScoresCommand do
  let(:game) { create(:game) }
  # game factory creates 2 fake user_games via CreateFakeUsersCommand.
  # Retrieve them ordered by id for deterministic access.
  let(:user_games) { game.user_games.order(:id) }

  describe '#call' do
    subject(:result) { described_class.new(game: game, current_user_game: current_user_game).call }

    let(:current_user_game) { nil }

    context 'return shape' do
      it 'returns a hash with all top-level keys' do
        expect(result.keys).to match_array(%i[total_players online_players current_user_game_id players])
      end

      it 'includes all expected keys in each player hash' do
        expected_keys = %i[rank id email civilization score total_land research_levels online]
        result[:players].each do |player|
          expect(player.keys).to match_array(expected_keys)
        end
      end
    end

    context 'player counts' do
      it 'sets total_players equal to the number of user_games for the game' do
        expect(result[:total_players]).to eq(game.user_games.count)
      end
    end

    context 'ordering — score descending, id ascending on tie' do
      before do
        user_games[0].update_columns(score: 200)
        user_games[1].update_columns(score: 100)
      end

      it 'orders players by score descending' do
        scores = result[:players].map { |p| p[:score] }
        expect(scores).to eq(scores.sort.reverse)
      end

      it 'assigns rank 1 to the highest-scoring player' do
        expect(result[:players].first[:rank]).to eq(1)
      end

      it 'assigns rank 2 to the second player' do
        expect(result[:players].second[:rank]).to eq(2)
      end
    end

    context 'tie-breaking by id ascending' do
      before do
        # Give all user_games the same score so they sort purely by id
        user_games.each { |ug| ug.update_columns(score: 500) }
      end

      it 'breaks ties by id ascending' do
        ids = result[:players].map { |p| p[:id] }
        expect(ids).to eq(ids.sort)
      end
    end

    context 'rank increments sequentially' do
      it 'assigns consecutive ranks starting at 1' do
        ranks = result[:players].map { |p| p[:rank] }
        expect(ranks).to eq((1..ranks.length).to_a)
      end
    end

    context 'online flag' do
      it 'marks a player as online when updated_at is less than 10 minutes ago' do
        user_games[0].update_columns(updated_at: 5.minutes.ago)
        player = result[:players].find { |p| p[:id] == user_games[0].id }
        expect(player[:online]).to be true
      end

      it 'marks a player as offline when updated_at is 10 or more minutes ago' do
        user_games[0].update_columns(updated_at: 11.minutes.ago)
        player = result[:players].find { |p| p[:id] == user_games[0].id }
        expect(player[:online]).to be false
      end
    end

    context 'online_players count' do
      before do
        user_games[0].update_columns(updated_at: 3.minutes.ago)
        user_games[1].update_columns(updated_at: 15.minutes.ago)
      end

      it 'counts only players who are currently online' do
        expect(result[:online_players]).to eq(1)
      end
    end

    context 'current_user_game_id' do
      context 'when a participant user_game is passed' do
        let(:current_user_game) { user_games[0] }

        it 'returns the id of the passed user_game' do
          expect(result[:current_user_game_id]).to eq(user_games[0].id)
        end
      end

      context 'when nil is passed (spectator)' do
        let(:current_user_game) { nil }

        it 'returns nil' do
          expect(result[:current_user_game_id]).to be_nil
        end
      end
    end

    context 'player data fields' do
      it 'includes the player email' do
        player = result[:players].first
        expect(player[:email]).to be_present
      end

      it 'includes the civilization name' do
        player = result[:players].first
        expect(player[:civilization]).to be_present
      end

      it 'computes total_land as m_land + f_land + p_land' do
        ug = user_games[0]
        ug.update_columns(m_land: 10, f_land: 20, p_land: 30)
        player = result[:players].find { |p| p[:id] == ug.id }
        expect(player[:total_land]).to eq(60)
      end

      it 'computes research_levels as the sum of all research column values' do
        ug = user_games[0]
        expected = UserGame::RESEARCHES.keys.sum { ug.send("#{_1}_researches").to_i }
        player = result[:players].find { |p| p[:id] == ug.id }
        expect(player[:research_levels]).to eq(expected)
      end
    end
  end
end
