FactoryBot.define do
  factory :admin, class: 'Users::Admin' do
    type { "Users::Admin" }
    full_name { Faker::Name.name }
    telephone { Faker::Number.unique.number(digits: 9).to_s }
    password { "password" }
    password_confirmation { "password" }
    role { 'operator' }

    association :enterprise
    association :branch

    trait :manager do
      role { 'manager' }
    end

    trait :operator do
      role { 'operator' }
    end

    trait :confirmed do
      association :invited_by, factory: :admin
      confirmed { true }
      invited_at { nil }
    end

    trait :unconfirmed do
      invited_at { DateTime.current }
    end
  end
end
