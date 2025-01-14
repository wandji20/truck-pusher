require 'rails_helper'

RSpec.describe Delivery, type: :model do
  subject { create(:delivery) }

  it { should belong_to(:receiver).class_name("Users::Customer") }

  it { should belong_to(:origin).class_name("Branch").optional }
  it { should belong_to(:destination).class_name("Branch") }

  it { should belong_to(:registered_by).class_name("Users::Admin") }
  it { should belong_to(:checked_in_by).class_name("Users::Admin").optional }
  it { should belong_to(:checked_out_by).class_name("Users::Admin").optional }

  it { should validate_uniqueness_of(:tracking_number).scoped_to(:enterprise_id) }
  it { should validate_uniqueness_of(:tracking_secret).scoped_to(:enterprise_id) }
end
