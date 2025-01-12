FactoryBot.define do
  factory :marketer do
    full_name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password" }
    password_confirmation { "password" }
    enterprises_count { 1 }
  end
end
