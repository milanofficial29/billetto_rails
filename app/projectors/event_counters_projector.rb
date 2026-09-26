class EventCountersProjector
  def call(event)
    case event
    when VoteCasted
      increment_counter(event.data[:event_id], event.data[:vote_type])
    when VoteRemoved
      decrement_counter(event.data[:event_id], event.data[:old_vote_type])
    when VoteChanged
      decrement_counter(event.data[:event_id], event.data[:old_vote_type])
      increment_counter(event.data[:event_id], event.data[:new_vote_type])
    end
  end

  private

  def increment_counter(event_id, type)
    column = type == 'like' ? :like_count : :dislike_count
    Event.increment_counter(column, event_id)
  end

  def decrement_counter(event_id, type)
    column = type == 'like' ? :like_count : :dislike_count
    Event.decrement_counter(column, event_id)
  end
end
