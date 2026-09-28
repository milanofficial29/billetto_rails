FactoryBot.define do
  factory :event do
    sequence(:external_id) { |n| "ext-#{n}" }
    title         { "Test Event" }
    description   { "A test event description" }
    starts_at     { 1.week.from_now }
    ends_at       { 1.week.from_now + 2.hours }
    image_url     { "https://picsum.photos/200/300?grayscale" }
    billetto_url  { "https://billetto.dk/e/test-event" }
    available     { true }
    like_count    { 0 }
    dislike_count { 0 }
  end
end