FactoryBot.define do
  factory :customer, class: "Users::Customer" do
    type { "Users::Customer" }
    full_name { Faker::Name.name }
    telephone { Faker::Number.unique.number(digits: 9).to_s }
    password { "password" }
    password_confirmation { "password" }
  end
end
