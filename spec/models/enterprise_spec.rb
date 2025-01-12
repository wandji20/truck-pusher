require 'rails_helper'

RSpec.describe Enterprise, type: :model do
  subject { create(:enterprise) }

  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_least(described_class::MIN_NAME_LENGTH) }
  it { should validate_length_of(:name).is_at_most(described_class::MAX_NAME_LENGTH) }
  it { should have_many(:branches).dependent(:destroy) }
  it { should have_many(:sessions).dependent(:destroy) }
  it { should have_many(:managers).class_name("Users::Admin").dependent(:destroy) }
end