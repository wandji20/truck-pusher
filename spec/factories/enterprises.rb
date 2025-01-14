FactoryBot.define do
  factory :enterprise do
    name { Faker::Company.unique.name }
    category { 0 }

    trait :merchant do
      category { "merchant" }
      description { Faker::Lorem.paragraph }
      city { Faker::Address.city }
    end
  end
end
