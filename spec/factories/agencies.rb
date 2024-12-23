FactoryBot.define do
  factory :agency do
    name { Faker::Company.unique.name }
  end
end
