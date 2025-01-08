module Users
  class Admin < User
    # Enums
    enum :role, %i[operator manager]

    # Validations
    validates :full_name, presence: true,
                length: { within: (MIN_NAME_LENGTH..MAX_NAME_LENGTH) }, if: -> { full_name.present? }
    validates :role, presence: true

    # Associations
    belongs_to :branch, optional: true
    belongs_to :invited_by, class_name: "Users::Admin", optional: true
    acts_as_tenant :agency

    def create_delivery(params)
      sender_params = params.delete(:sender)
      receiver_params = params.delete(:receiver)

      delivery = Delivery.new(params.merge({ registered_by: self, origin: self.branch }))

      ActiveRecord::Base.transaction do
        delivery = set_customer(sender_params, delivery, :sender)
        delivery = set_customer(receiver_params, delivery, :receiver)

        delivery.save!
      end
      delivery

    rescue ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation
      delivery
    end

    def invite_user(params)
      agency = params.delete(:agency)
      ActsAsTenant.with_tenant(agency) do
        new_user = if user = Users::Admin.where(confirmed: false).find_by(telephone: params[:telephone])
                      user.invited_at = Time.current
                      user.invited_by_id = self.id
                      user
        else
                      password = SecureRandom.hex(8)
                      Users::Admin.new(params.merge({ invited_by_id: self.id, invited_at: Time.current,
                          password:, password_confirmation: password, branch: self.branch }))
        end

        ActiveRecord::Base.transaction do
          new_user.save!
          # token = new_user.generate_token_for(:invitation)
          # edit_user_invitation_url(new_user, params: { token:, agency_name: agency.name }, host: "localhost:3000")
          # Send message
          new_user
        end
      rescue ActiveRecord::RecordInvalid
        new_user
      end
    end

    generates_token_for :invitation, expires_in: 1.week do
      invited_at
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
      attrs.merge!(password:, password_confirmation: password)

      new_customer = Users::Customer.new(attrs)
      new_customer.valid?
      new_customer
    end
  end
end
