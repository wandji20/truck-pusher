class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true
  delegate :marketer, to: :session, allow_nil: true
  delegate :enterprise, to: :session, allow_nil: true
end
