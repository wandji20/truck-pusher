FactoryBot.define do
  factory :customer, class: 'User' do
    full_name { Faker::Name.name }
    telephone { Faker::PhoneNumber.unique.phone_number }
    password { "password" }
    password_confirmation { "password" }
  end
end
