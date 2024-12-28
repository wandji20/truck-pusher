require 'rails_helper'

RSpec.describe Users::Admin, type: :model do
  it { should validate_presence_of(:full_name) }
  it { should validate_length_of(:full_name).is_at_least(described_class::MIN_NAME_LENGTH) }
  it { should validate_length_of(:full_name).is_at_most(described_class::MAX_NAME_LENGTH) }
  it { should belong_to(:agency) }

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
end
