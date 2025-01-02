# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Agency do |agency|
      user.agency_id == agency.id && user.general_manager?
    end

    can :manage, Branch do |branch|
      return unless user.agency_id == branch.agency_id
      user.general_manager? || user.manager?
    end

    can :manage, Delivery do |delivery|
      return unless delivery.agency_id == user.agency_id
      return unless user.operator? || user.manager? || user.general_manager?

      [ delivery.origin_id, delivery.destination_id ].include?(user.branch_id) ||
        user.general_manager?
    end
  end
end
