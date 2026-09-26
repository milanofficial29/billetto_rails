require 'rails_helper'

RSpec.describe Event, type: :model do
  subject { build(:event) }
  
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:starts_at) }
  it { is_expected.to validate_presence_of(:external_id) }
  it { is_expected.to validate_uniqueness_of(:external_id).ignoring_case_sensitivity }
  it { is_expected.to validate_numericality_of(:like_count).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:dislike_count).is_greater_than_or_equal_to(0) }
end