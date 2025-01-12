require 'rails_helper'

RSpec.describe Marketer, type: :model do
  subject { create(:marketer) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }

  it { should have_many(:enterprises) }
end
