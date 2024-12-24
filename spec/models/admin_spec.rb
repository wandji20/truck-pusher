require 'rails_helper'

RSpec.describe Users::Admin, type: :model do
  it { should validate_presence_of(:full_name) }
  it { should validate_length_of(:full_name).is_at_least(described_class::MIN_NAME_LENGTH) }
  it { should validate_length_of(:full_name).is_at_most(described_class::MAX_NAME_LENGTH) }
  it { should belong_to(:agency) }
end
