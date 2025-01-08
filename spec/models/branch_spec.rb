require 'rails_helper'

RSpec.describe Branch, type: :model do
  subject { create(:branch) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:agency_id) }
  it { should validate_length_of(:name).is_at_least(described_class::MIN_NAME_LENGTH) }
  it { should validate_length_of(:name).is_at_most(described_class::MAX_NAME_LENGTH) }
  it { should validate_presence_of(:telephone) }
  it { should validate_uniqueness_of(:telephone).scoped_to(:agency_id).case_insensitive }
  it { should have_many(:operators).class_name("Users::Admin").dependent(:destroy) }
end
