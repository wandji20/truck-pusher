require 'rails_helper'

RSpec.describe Marketer, type: :model do
  subject { create(:marketer) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }

  it { should have_many(:enterprises) }

  describe "#invite_new" do
    let(:marketers) { create_list(:marketer, 5, :confirmed) }

    it "invites new marketer" do
      new_marketer = described_class.invite_new({ email: "new@email.com" })
      expect(new_marketer.persisted?).to be_truthy
    end

    it "resends new invite if marketer is unconfirmed" do
      marketer = create(:marketer)
      new_marketer = described_class.invite_new({ email: marketer.email })

      expect(new_marketer.errors).to be_empty
    end

    it "fails to invite new with confirmed account" do
      new_marketer = described_class.invite_new({ email: marketers.first.email })
      expect(new_marketer.persisted?).to be_falsey
      expect(new_marketer.errors.messages[:email]).to include(/has already been taken/)
    end
  end
end
