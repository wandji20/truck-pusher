# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :create_merchant, Enterprise do |enterprise|
      user.instance_of?(Marketer)
    end

    can :manage, Enterprise do |enterprise|
      user.try(:enterprise_id) == enterprise.id && user.try(:manager?)
    end

    can :create, Delivery do
      return unless user.enterprise_id == enterprise.id

      user.operator? || user.manager?
    end

    can :manage, Delivery do |delivery|
      user.enterprise.category == "merchant" && # merchants can't update deliveries
      user.operator? || user.manager? &&
      delivery.enterprise_id == user.enterprise_id &&
      [ delivery.origin_id, delivery.destination_id ].include?(user.branch_id)
    end
  end
end
