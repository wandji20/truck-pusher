module Users
  class Customer < User
    # Validations
    validates :full_name, presence: true,
                length: { within: (MIN_NAME_LENGTH..MAX_NAME_LENGTH) }
  end
end
