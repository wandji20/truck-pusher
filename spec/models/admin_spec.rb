require 'rails_helper'

RSpec.describe Users::Admin, type: :model do
  subject { create(:admin, :manager, telephone: "674895621") }

  it { should validate_presence_of(:password) }
  it { should validate_length_of(:password).is_at_least(described_class::MIN_PASSWORD_LENGTH) }
  it { should validate_length_of(:password).is_at_most(described_class::MAX_PASSWORD_LENGTH) }
  it { should validate_presence_of(:telephone) }
  it { should validate_uniqueness_of(:telephone).scoped_to(:enterprise_id).case_insensitive }
  it { should validate_presence_of(:role) }
  it { should belong_to(:branch).optional }
  it { should belong_to(:invited_by).optional }
  it { should have_many(:sessions).dependent(:destroy) }

  describe "validating telephone format" do
    context 'bad format' do
      subject { build(:admin, telephone: '124587') }
      it 'fails with invalid telephone' do
        expect(subject.valid?).to be(false)
        expect(subject.errors.full_messages).to include(/Telephone is invalid/)
      end
    end

    context 'correct format' do
      subject { build(:admin, :manager, telephone: '123654789') }
      it 'accepts correct telephone' do
        expect(subject.valid?).to be(true)
        expect(subject.errors.full_messages).to_not include(/Telephone is invalid/)
      end
    end

    context 'correct format with invalid start and end characters' do
      subject { build(:admin, telephone: '~123654789!') }
      it 'fails with invalid telephone' do
        expect(subject.valid?).to be(false)
        expect(subject.errors.full_messages).to include(/Telephone is invalid/)
      end
    end
  end


  describe "#create delivery" do
    let!(:enterprise) { create(:enterprise, category: "agency") }
    let!(:branches) { create_list(:branch, 4) }
    let(:operator) { create(:admin, :operator, :confirmed, enterprise:, branch: branches.first) }
    let!(:customers) { create_list(:customer, 5) }

    context "valid attributes" do
      it "creates new delivery with existing customer record" do
        params = { sender_id: customers.first.id, receiver_id: customers.last.id,
                   enterprise_id: enterprise.id, destination_id: branches.last.id }
        delivery = operator.create_delivery(params)
        expect(delivery.persisted?).to be_truthy
      end

      it 'creates new delivery alongside new customer' do
        customers_count = Users::Customer.count
        sender = build(:customer)
        receiver = build(:customer)
        params = { sender: { full_name: sender.full_name, telephone: sender.telephone },
                   receiver: { full_name: receiver.full_name, telephone: receiver.telephone },
                   enterprise_id: enterprise.id, destination_id: branches.last.id }

        delivery = operator.create_delivery(params)
        expect(delivery.persisted?).to be_truthy
        expect(Users::Customer.count).to be(customers_count + 2)
      end
    end

    context "invalid attributes" do
      it "fails to create new delivery when sender or receiver is absent" do
        params = { enterprise_id: enterprise.id, destination_id: branches.last.id }
        delivery = operator.create_delivery(params)
        expect(delivery.persisted?).to be_falsey
        expect(delivery.errors[:sender]).to include("can't be blank")
        expect(delivery.errors[:receiver]).to include("must exist")
      end

      it "fails to create new delivery when sender or receiver attribute is invalid" do
        params = { sender: { full_name: "t", telephone: "" },
                   receiver: { full_name: "", telephone: "1245" },
                   enterprise_id: enterprise.id, destination_id: branches.last.id }
        delivery = operator.create_delivery(params)
        expect(delivery.persisted?).to be_falsey
        expect(delivery.sender.errors.messages[:full_name]).to include("is too short (minimum is 2 characters)")
        expect(delivery.sender.errors.messages[:telephone]).to include("is invalid")
        expect(delivery.sender.errors.messages[:telephone]).to include("can't be blank")
        expect(delivery.receiver.errors.messages[:full_name]).to include("can't be blank")
        expect(delivery.receiver.errors.messages[:telephone]).to include("is invalid")
      end
    end
  end

  describe "#invite_user" do
    let(:enterprise) { create(:enterprise) }
    let(:branch) { create(:branch, enterprise:) }
    let(:admin) { create(:admin, :manager, :confirmed, enterprise:, branch:) }

    it "invites new user" do
      new_user = admin.invite_user({ telephone: '632154785', role: :manager, enterprise: })
      expect(new_user.persisted?).to be_truthy
    end

    it "resends new user invite if user is unconfirmed" do
      user = create(:admin, :manager, telephone: "632154785")

      new_user = admin.invite_user({ telephone: '632154785', role: :manager, enterprise:, branch: })
      expect(user.invited_by).to be_nil
      expect(new_user.persisted?).to be_truthy
      expect(new_user.invited_by_id).to be(admin.id)
    end

    it "fails to invite new user with confirmed account" do
      create(:admin, :confirmed, :manager, telephone: "632154785", enterprise:)

      new_user = admin.invite_user({ telephone: '632154785', role: :manager, enterprise: })
      expect(new_user.persisted?).to be_falsey
      expect(new_user.errors.messages[:telephone]).to include(/has already been taken/)
    end
  end
end
