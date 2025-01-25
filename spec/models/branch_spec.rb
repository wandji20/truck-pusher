require 'rails_helper'

RSpec.describe Branch, type: :model do
  subject { create(:branch) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:enterprise_id) }
  it { should validate_length_of(:name).is_at_least(described_class::MIN_NAME_LENGTH) }
  it { should validate_length_of(:name).is_at_most(described_class::MAX_NAME_LENGTH) }
  it { should validate_presence_of(:telephone) }
  it { should validate_uniqueness_of(:telephone).scoped_to(:enterprise_id).case_insensitive }
  it { should have_many(:operators).class_name("Users::Admin").dependent(:destroy) }

  describe "#create_new" do
    let!(:enterprise) { create(:enterprise) }
    let!(:manager) { create(:admin, :confirmed, :manager, enterprise:, branch: nil) }

    it "create new branch with valid params" do
      expect(manager.branch).to be_nil
      branch = described_class.create_new({ name: "Branch One", telephone: "678454785", enterprise:, user: manager })
      expect(branch.persisted?).to be_truthy
      expect(manager.branch).to eq(branch)
      expect(branch.name).to match("Branch One")
    end

    it "fails to create branch with invalid params" do
      branch = described_class.create_new({ name: "e", telephone: "6784585", enterprise:, user: manager })
      expect(branch.persisted?).to be_falsey
      expect(manager.branch).to be_nil
      expect(branch.errors.messages[:name]).to include("is too short (minimum is 2 characters)")
      expect(branch.errors.messages[:telephone]).to include("is invalid")
    end
  end
end
