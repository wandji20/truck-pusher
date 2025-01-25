require 'rails_helper'

RSpec.describe Users::Customer, type: :model do
  subject { create(:customer) }

  it { should validate_presence_of(:full_name) }
  it { should validate_length_of(:full_name).is_at_least(described_class::MIN_NAME_LENGTH) }
  it { should validate_length_of(:full_name).is_at_most(described_class::MAX_NAME_LENGTH) }
  it { should validate_presence_of(:telephone) }
  it { should validate_uniqueness_of(:telephone).scoped_to(:enterprise_id).case_insensitive }
  it { should_not belong_to(:enterprise) }

  describe "validating telephone format" do
    context 'bad format' do
      subject { build(:customer, telephone: '124587') }
      it 'fails with invalid telephone' do
        expect(subject.valid?).to be(false)
        expect(subject.errors.full_messages).to include(/Telephone is invalid/)
      end
    end

    context 'correct format' do
      subject { build(:customer, telephone: '123654789') }
      it 'accepts correct telephone' do
        expect(subject.valid?).to be(true)
        expect(subject.errors.full_messages).to_not include(/Telephone is invalid/)
      end
    end

    context 'correct format with invalid start and end characters' do
      subject { build(:customer, telephone: '~123654789!') }
      it 'fails with invalid telephone' do
        expect(subject.valid?).to be(false)
        expect(subject.errors.full_messages).to include(/Telephone is invalid/)
      end
    end
  end
end
