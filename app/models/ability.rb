# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Enterprise do |enterprise|
      user.enterprise_id == enterprise.id && user.manager?
    end

    can :manage, Delivery do |delivery|
      return unless delivery.enterprise_id == user.enterprise_id
      return unless user.operator? || user.manager?

      [ delivery.origin_id, delivery.destination_id ].include?(user.branch_id)
    end
  end
end
