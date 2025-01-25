class Session < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :marketer, optional: true

  acts_as_tenant :enterprise, optional: true
end
