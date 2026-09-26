class EventsController < ApplicationController
  def index
    Pagy::OPTIONS[:limit] = 24
    @pagy, @events = pagy(Event.all)
  end
end
