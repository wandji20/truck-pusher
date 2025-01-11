FactoryBot.define do
  factory :branch do
    name { Faker::Address.unique.community }
    telephone { Faker::Number.unique.number(digits: 9).to_s }

    association :enterprise
  end
end
