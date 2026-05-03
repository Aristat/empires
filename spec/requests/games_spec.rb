# frozen_string_literal: true

RSpec.describe 'Games', type: :request do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:civilization) { game.civilizations.first }
  let!(:user_game) do
    create(:user_game, user: user, game: game, civilization: civilization)
  end

  describe 'GET /games/:id/scores' do
    context 'when authenticated as a participant' do
      before { sign_in user }

      it 'returns 200' do
        get scores_game_path(game)
        expect(response).to have_http_status(:ok)
      end

      it 'renders the scores page' do
        get scores_game_path(game)
        expect(response.body).to include(user.email)
      end
    end

    context 'when authenticated as a non-participant (spectator)' do
      let(:other_user) { create(:user) }

      before { sign_in other_user }

      it 'returns 200' do
        get scores_game_path(game)
        expect(response).to have_http_status(:ok)
      end

      it 'still renders the scores table' do
        get scores_game_path(game)
        expect(response.body).to include(user.email)
      end
    end

    context 'when unauthenticated' do
      it 'redirects to login' do
        get scores_game_path(game)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when game does not exist' do
      before { sign_in user }

      it 'returns 404' do
        get scores_game_path(id: 0)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
