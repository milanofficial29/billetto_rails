require "rails_event_store"
require "aggregate_root"
require "arkency/command_bus"

require_relative "../../app/events/vote_events"

Rails.configuration.to_prepare do
  event_store = RailsEventStore::Client.new
  Rails.configuration.event_store = event_store

  repository = AggregateRoot::Repository.new(event_store)

  # Subscribe our projector to the events synchronously
  event_store.subscribe(
    EventCountersProjector.new,
    to: [VoteCasted, VoteChanged, VoteRemoved]
  )
end
