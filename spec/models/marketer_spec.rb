require 'rails_helper'

RSpec.describe Marketer, type: :model do
  subject { create(:marketer) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }

  it { should have_many(:merchants) }

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

  describe "#create_merchant" do
    let!(:marketer) { create(:marketer, :confirmed) }
    let(:merchant_params) { { name: "New Merchant", city: "Bamenda", description: "Test description" } }
    let(:manager_params) { { telephone: "698745621" } }
    it "creates new merchant and manager with valid params" do
      merchant, manager = marketer.create_merchant(merchant_params, manager_params)

      expect(merchant.persisted?).to be_truthy
      expect(manager.persisted?).to be_truthy
      expect(manager.enterprise).to be(merchant)
      expect(marketer.enterprises_count).to eq(1)
     end

    it "falis to create new merchant and manager with invalid params" do
      merchant, manager = marketer.create_merchant({ city: "", name: "", description: "" }, { telephone: "" })
      expect(merchant.persisted?).to be_falsey
      expect(manager.persisted?).to be_falsey
      expect(merchant.errors.messages[:city]).to include("can't be blank")
      expect(merchant.errors.messages[:name]).to include("can't be blank")
      expect(merchant.errors.messages[:name]).to include("is too short (minimum is 2 characters)")
      expect(merchant.errors.messages[:description]).to include("can't be blank")
      expect(manager.errors.messages[:telephone]).to include("is invalid")
     end

    it "falis to create new merchant and manager with one invalid params" do
      merchant, manager = marketer.create_merchant(merchant_params, { telephone: "" })

      expect(merchant.persisted?).to be_falsey
      expect(manager.persisted?).to be_falsey
      expect(merchant.errors.messages[:managers]).to include("is invalid")

      expect(manager.errors.messages[:telephone]).to include("is invalid")
     end
  end
end
