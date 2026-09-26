class CastVoteService
  def initialize(event_id:, user_id:, event_store: Rails.configuration.event_store)
    @event_id = event_id
    @user_id = user_id
    @event_store = event_store
    @stream_name = "EventUserVote$#{event_id}_#{user_id}"
  end

  def call(new_vote_type) # 'like', 'dislike', or nil (to remove)
    current_state = determine_current_state
    
    if current_state.nil? && new_vote_type.present?
      # Brand new vote
      publish_event(VoteCasted, vote_type: new_vote_type)
    elsif current_state.present? && new_vote_type.nil?
      # Removing an existing vote
      publish_event(VoteRemoved, old_vote_type: current_state)
    elsif current_state.present? && current_state != new_vote_type
      # Switching from like to dislike or vice versa
      publish_event(VoteChanged, old_vote_type: current_state, new_vote_type: new_vote_type)
    end
  end

  def determine_current_state
    # Read the very last event from this specific user-event stream
    last_event = @event_store.read.stream(@stream_name).backward.limit(1).first
    return nil unless last_event

    case last_event.class.name
    when 'VoteCasted'  then last_event.data[:vote_type]
    when 'VoteChanged' then last_event.data[:new_vote_type]
    when 'VoteRemoved' then nil
    end
  end

  private

  def publish_event(event_klass, data)
    event = event_klass.new(data: data.merge(event_id: @event_id, user_id: @user_id))
    @event_store.publish(event, stream_name: @stream_name)
  end
end