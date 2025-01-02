require 'rails_helper'

RSpec.describe Users::Admin, type: :model do
  subject { create(:admin, telephone: "674895621") }

  it { should validate_presence_of(:full_name) }
  it { should validate_length_of(:full_name).is_at_least(described_class::MIN_NAME_LENGTH) }
  it { should validate_length_of(:full_name).is_at_most(described_class::MAX_NAME_LENGTH) }
  it { should validate_presence_of(:telephone) }
  it { should validate_uniqueness_of(:telephone).scoped_to(:agency_id).case_insensitive }

  describe "validating telephone format" do
    context 'bad format' do
      subject { build(:admin, telephone: '124587') }
      it 'fails with invalid telephone' do
        expect(subject.valid?).to be(false)
        expect(subject.errors.full_messages).to include(/Telephone is invalid/)
      end
    end

    context 'correct format' do
      subject { build(:admin, telephone: '123654789') }
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
    let!(:agency) { create(:agency) }
    let!(:branches) { create_list(:branch, 4) }
    let!(:operator) { create(:admin, :confirmed, :operator, agency:, branch: branches.first) }
    let!(:customers) { create_list(:customer, 5) }

    context "valid attributes" do
      it "creates new delivery with existing customer record" do
        params = { sender_id: customers.first.id, receiver_id: customers.last.id,
                   agency_id: agency.id, destination_id: branches.last.id }
        delivery = operator.create_delivery(params)
        expect(delivery.persisted?).to be_truthy
      end

      it 'creates new delivery alongside new customer' do
        customers_count = Users::Customer.count
        sender = build(:customer)
        receiver = build(:customer)
        params = { sender: { full_name: sender.full_name, telephone: sender.telephone },
                   receiver: { full_name: receiver.full_name, telephone: receiver.telephone },
                   agency_id: agency.id, destination_id: branches.last.id }

        delivery = operator.create_delivery(params)
        expect(delivery.persisted?).to be_truthy
        expect(Users::Customer.count).to be(customers_count + 2)
      end
    end

    context "invalid attributes" do
      it "fails to create new delivery when sender or receiver is absent" do
        params = { agency_id: agency.id, destination_id: branches.last.id }
        delivery = operator.create_delivery(params)
        expect(delivery.persisted?).to be_falsey
        expect(delivery.errors[:sender]).to include("must exist")
        expect(delivery.errors[:receiver]).to include("must exist")
      end

      it "fails to create new delivery when sender or receiver attribute is invalid" do
        params = { sender: { full_name: "t", telephone: "" },
                   receiver: { full_name: "", telephone: "1245" },
                   agency_id: agency.id, destination_id: branches.last.id }
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
end
