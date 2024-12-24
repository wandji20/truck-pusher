FactoryBot.define do
  factory :admin, class: 'Users::Admin' do
    full_name { Faker::Name.name }
    telephone { Faker::PhoneNumber.unique.phone_number }
    password { "password" }
    password_confirmation { "password" }

    association :agency
    association :branch

    trait :manager do
      role { 'manager' }
    end

    trait :operator do
      role { 'operator' }
    end

    trait :confirmed do
      association :invited_by, factory: :admin
      invited_at { DateTime.current }
      confirmed { true }
    end
  end
end