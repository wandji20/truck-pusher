require 'rails_helper'

RSpec.describe Enterprise, type: :model do
  subject { create(:enterprise) }

  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_least(described_class::MIN_NAME_LENGTH) }
  it { should validate_length_of(:name).is_at_most(described_class::MAX_NAME_LENGTH) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:category) }

  it { should belong_to(:marketer).optional }
  it { should have_many(:branches).dependent(:destroy) }
  it { should have_many(:sessions).dependent(:destroy) }
  it { should have_many(:managers).class_name("Users::Admin").dependent(:destroy) }

  describe "#create_new" do
    it "create manager and agency with valid params" do
      agency, manager = described_class.create_new({ name: "Agency One" }, { telephone: "678954215" })
      expect(agency.persisted?).to be_truthy
      expect(manager.persisted?).to be_truthy
      expect(agency.name).to match("Agency One")
      expect(manager.telephone).to match("678954215")
    end

    it "fails to create manager and agency with invalid params" do
      agency, manager = described_class.create_new({ name: "e" }, { telephone: "67215" })
      expect(agency.persisted?).to be_falsey
      expect(manager.persisted?).to be_falsey
      expect(agency.errors.messages[:name]).to include("is too short (minimum is 2 characters)")
      expect(manager.errors.messages[:telephone]).to include("is invalid")
    end
  end
end
