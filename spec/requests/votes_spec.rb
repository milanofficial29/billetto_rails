require 'rails_helper'

RSpec.describe 'Votes', type: :request do
  let(:event) { create(:event) }

  describe 'POST /votes' do
    context 'when not signed in' do
      before { sign_out }

      it 'redirects to root without dispatching any command' do
        post "/events/#{event.id}/vote", params: { type: 'like' }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when signed in' do
      before { sign_in_as(user_id: 'usr_test') }

      it 'dispatches VoteCasted for vote type=like' do
        post "/events/#{event.id}/vote", params: { type: 'like' }
        event.reload
        expect(event.like_count).to eq(1)
      end

      it 'dispatches VoteCasted for vote type=dislike' do
        post "/events/#{event.id}/vote", params: { type: 'dislike' }
        event.reload
        expect(event.dislike_count).to eq(1)
      end

      it 'dispatches VoteChanged from like to dislike' do
        post "/events/#{event.id}/vote", params: { type: 'like' }
        event.reload
        expect(event.like_count).to eq(1)

        post "/events/#{event.id}/vote", params: { type: 'dislike' }
        event.reload
        expect(event.dislike_count).to eq(1)
        expect(event.like_count).to eq(0)
      end

      it 'dispatches VoteRemoved from like' do
        post "/events/#{event.id}/vote", params: { type: 'like' }
        event.reload
        expect(event.like_count).to eq(1)

        post "/events/#{event.id}/vote", params: { type: '' }
        event.reload
        expect(event.like_count).to eq(0)
      end

      it 'returns error when invalid vote type' do
        post "/events/#{event.id}/vote", params: { type: 'sideways' }
        expect(flash[:error]).to eq("Invalid vote type selection.")
      end

      it 'returns error when event is missing' do
        post "/events/0/vote", params: { type: 'like' }
        expect(flash[:error]).to eq("Event not found.")
      end
    end
  end
end