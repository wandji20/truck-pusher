FactoryBot.define do
  factory :branch do
    name { Faker::Address.unique.community }

    association :agency
  end
end
