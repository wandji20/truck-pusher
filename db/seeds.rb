# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
ENTERPRISES = [
  { name: "Moghamo", branches: [ "Bamenda", "Yaounde", "Douala", "Limbe" ] },
  { name: "Vatican", branches: [ "Bamenda", "Yaounde", "Douala", "Limbe" ] },
  { name: "Nso Boyz", branches: [ "Bamenda", "Yaounde", "Douala", "Limbe" ] },
  { name: "Garanti", branches: [ "Bamenda", "Yaounde", "Douala", "Limbe" ] },
  { name: "Golden", branches: [ "Kumba", "Buea", "Douala" ] }
]

def create_default_enterprise_and_branches
  enterprise = Enterprise.create(name: "Truck Pusher", category: :special)
  ActsAsTenant.with_tenant(enterprise) do
    password = "password"
    [ "Bamenda", "Limbe", "Buea", "Douala", "Yaounde", "Kumba", "Bafoussam" ].each_with_index do |name, idx|
      branch = Branch.create(name:, telephone: "6203099#{enterprise.id}#{idx}")
      telephone = "69#{(branch.id.to_s + idx.to_s).rjust(3, "0")}5621"

      enterprise.managers.create!(full_name: "#{name} Admin", telephone:, password:,
                                    password_confirmation: password, confirmed: true, role: :manager, branch:)
    end
  end
end

def create_enterprises_and_branches
  ENTERPRISES.each_with_index do |details, idx|
    password = "password"
    enterprise = Enterprise.create!(name: details[:name])

    ActsAsTenant.with_tenant(enterprise) do
      details[:branches].each_with_index do |name, idx|
        branch = enterprise.branches.create!(name:, telephone: "6203098#{enterprise.id}#{idx}")
        telephone = "67#{(branch.id.to_s + idx.to_s).rjust(3, "0")}5621"
        manager = enterprise.managers.create!(full_name: "#{details[:name]} Admin", telephone:, password:,
                                          password_confirmation: password, confirmed: true, role: :manager, branch:)
        # Create 3 operators for each branch
        3.times do |n|
          telephone = "65249#{(branch.id.to_s + idx.to_s + n.to_s).rjust(4, "0")}"
          branch.operators.create!(full_name: "#{details[:name]}-#{name} Operator-#{n + 1}",
                                    telephone:, password:, password_confirmation: password,
                                    confirmed: true, role: :operator, branch:, invited_by: manager, invited_at: Time.current)
        end
      end
    end
  end
end

def create_customers_and_deliveries
  30.times do |number|
    telephone = "6824521#{number.to_s.rjust(2, "0")}"
    password = 'password'

    Users::Customer.create!(full_name: Faker::Name.name, telephone:, password:,
                            password_confirmation: password)
  end

  customer_ids = Users::Customer.pluck(:id)

  Enterprise.all.each do |enterprise|
    ActsAsTenant.with_tenant(enterprise) do
      branch_ids = enterprise.branch_ids
      enterprise.branches.each do |branch|
        # create 10 deliveries for each branch
        operator_ids = branch.operator_ids

        10.times do
          sender_id, receiver_id, = customer_ids.shuffle[3, 7]
          destination_id = branch_ids.select { |id| id != branch.id }.shuffle.sample
          registered_by_id = operator_ids.shuffle.sample || enterprise.manager_ids.first

          attrs =  { sender_id:, receiver_id:, origin_id: branch.id, destination_id:, registered_by_id: }

          sleep 1 # Avoid creating tracking number within thesame second
          Delivery.create!(attrs)
        end
      end
    end
  end
end

def create_markerters_and_merchants
  password = "password"
  4.times do |n|
    marketer = Marketer.create(full_name: Faker::Name.name, email: "marketer#{n}@email.com",
                                password:, password_confirmation: password, confirmed: true)
    [ 4, 5, 7 ].shuffle.sample.times do |i|
      merchant = marketer.merchants.create(name: "Merchant-#{i} (#{marketer.id})", description: Faker::Lorem.paragraph, city: Faker::Address.city)
      merchant.managers.create(full_name: "#{merchant.name} - manager", telephone: "67770002#{i}", password:,
                                password_confirmation: password, confirmed: true)
    end
  end
end

ActiveRecord::Base.transaction do
  p "Creating default Agency and Branches"
  create_default_enterprise_and_branches
  p "Creating enterprises and Branches"
  create_enterprises_and_branches
  p "Creating marketers and merchants"
  create_markerters_and_merchants
  p "Create customers and deliveries"
  create_customers_and_deliveries
end
