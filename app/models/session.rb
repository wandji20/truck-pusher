class Session < ApplicationRecord
  belongs_to :user
  acts_as_tenant :enterprise
end
