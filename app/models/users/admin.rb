module Users
  class Admin < User
    # Enums
    enum :role, %i[operator manager general_manager]

    # Associations
    belongs_to :branch, optional: true
    acts_as_tenant :agency

    def create_delivery(params)
      sender_params = params.delete(:sender)
      receiver_params = params.delete(:receiver)

      delivery = Delivery.new(params.merge({ registered_by: self, origin: self.branch }))

      User.transaction do
        delivery = set_customer(sender_params, delivery, :sender)
        delivery = set_customer(receiver_params, delivery, :receiver)

        delivery.save!
      end
      delivery

    rescue ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation
      p delivery.errors.messages
      delivery
    end

    private

    def set_customer(attrs, delivery, customer_type)
      case true
      when customer_type == :sender
        return delivery if delivery.sender_id? || attrs.nil?

        delivery.sender = create_customer(attrs)
      when customer_type == :receiver
        return delivery if delivery.receiver_id? || attrs.nil?

        delivery.receiver = create_customer(attrs)
      end

      delivery
    end

    def create_customer(attrs)
      password = SecureRandom.hex(8)
      attrs = attrs.merge(password:, password_confirmation: password)

      new_customer = Users::Customer.new(attrs)
      new_customer.valid?
      new_customer
    end
  end
end
