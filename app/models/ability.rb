# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Agency do |agency|
      user.agency_id == agency.id && user.manager?
    end

    can :manage, Delivery do |delivery|
      return unless delivery.agency_id == user.agency_id
      return unless user.operator? || user.manager?

      [ delivery.origin_id, delivery.destination_id ].include?(user.branch_id)
    end
  end
end
