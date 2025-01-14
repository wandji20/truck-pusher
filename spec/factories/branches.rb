FactoryBot.define do
  factory :branch do
    name { Faker::Lorem.unique.words(number: 2).join(' ') }
    telephone { Faker::Number.unique.number(digits: 9).to_s }

    association :enterprise
  end
end
