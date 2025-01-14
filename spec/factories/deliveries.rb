FactoryBot.define do
  factory :delivery do
    enterprise { association :enterprise }

    origin { association :branch }
    destination { association :branch }

    sender { association :customer }
    receiver { association :customer }

    registered_by { association :admin, :operator }

    tracking_number { Faker::Alphanumeric.alpha(number: 10) }
    tracking_secret { Faker::Alphanumeric.alpha(number: 10) }

    trait :checked_in do
      status { 'checked_in' }
      checked_in_by { association :admin, :operator }
      checked_in_at { Datetime.current }
    end

    trait :checked_out do
      status { 'checked_out' }
      checked_out_by { association :admin, :operator }
      checked_out_at { Datetime.current + [ 2, 4, 6, 8 ].sample.hours }
    end
  end
end
