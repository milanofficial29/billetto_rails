class Event < ApplicationRecord
  validates :like_count, :dislike_count, numericality: { greater_than_or_equal_to: 0 }
  validates :title,       presence: true
  validates :starts_at,   presence: true
  validates :external_id, presence: true, uniqueness: true
  
  # Fetch the voting state for a specific user on this event instance
  def user_vote_state(user)
    return nil unless user
    
    CastVoteService.new(event_id: id, user_id: user.id).determine_current_state
  end
end
