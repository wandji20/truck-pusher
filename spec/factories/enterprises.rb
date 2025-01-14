FactoryBot.define do
  factory :enterprise do
    name { Faker::Company.unique.name }
    category { 0 }
  end
end
