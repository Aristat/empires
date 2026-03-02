# frozen_string_literal: true

RSpec.describe 'GET /games/:id/scores', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:game) { create(:game) }
  # A user who already has a user_game in this game (participant).
  # The game factory's CreateFakeUsersCommand creates fake users using find_or_initialize_by
  # with predictable emails, so we can fetch the first fake user_game's user as a participant.
  let(:participant_user_game) { game.user_games.first }
  let(:participant) { participant_user_game.user }

  # An authenticated user who has NO user_game in this game (spectator).
  let(:spectator) { create(:user) }

  describe 'authentication' do
    context 'when the user is not authenticated' do
      it 'redirects to the login page (302)' do
        get scores_game_path(game)
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'as an authenticated participant (user with a user_game in this game)' do
    before { sign_in participant }

    it 'returns 200 OK' do
      get scores_game_path(game)
      expect(response).to have_http_status(:ok)
    end

    it 'renders the leaderboard page containing the total_players count' do
      get scores_game_path(game)
      expect(response.body).to include(game.user_games.count.to_s)
    end

    it 'renders each player email in the response body' do
      get scores_game_path(game)
      game.user_games.includes(:user).each do |ug|
        expect(response.body).to include(ug.user.email)
      end
    end

    it 'highlights the current user\'s row (current_user_game_id present in body)' do
      get scores_game_path(game)
      expect(response.body).to include(participant_user_game.id.to_s)
    end
  end

  describe 'as an authenticated spectator (user with no user_game in this game)' do
    before { sign_in spectator }

    it 'returns 200 OK' do
      get scores_game_path(game)
      expect(response).to have_http_status(:ok)
    end

    it 'renders the leaderboard page' do
      get scores_game_path(game)
      expect(response.body).to include('Leaderboard')
    end

    it 'renders player emails in the response body' do
      get scores_game_path(game)
      game.user_games.includes(:user).each do |ug|
        expect(response.body).to include(ug.user.email)
      end
    end
  end

  describe 'non-existent game' do
    before { sign_in spectator }

    it 'returns 404 when the game id does not exist' do
      get scores_game_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end
end
