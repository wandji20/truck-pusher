class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session
  delegate :agency, to: :session
end
