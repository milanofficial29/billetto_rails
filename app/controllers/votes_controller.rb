class VotesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_event

  def create
    # Normalize input: "like", "dislike", or nil (for removing a vote)
    vote_type = params[:type].presence 
    
    unless vote_type.nil?
      flash.now[:error] = "Invalid vote type selection." unless %w[like dislike].include?(vote_type)
			return respond_to do |format|
				format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash") }
			end
    end

    # 1. Execute the Rails Event Store Service
    CastVoteService.new(
      event_id: @event.id,
      user_id: current_user.id
    ).call(vote_type)

    # 2. Reload the event to get the updated cached counters from the projector
    @event.reload
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
		flash.now[:error] = "Event not found"
  end
end
