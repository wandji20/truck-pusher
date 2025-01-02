# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
AGENCIES = [
  { name: "Moghamo", branches: [ "Bamenda", "Yaounde", "Douala", "Limbe" ] },
  { name: "Vatican", branches: [ "Bamenda", "Yaounde", "Douala", "Limbe" ] },
  { name: "Nso Boyz", branches: [ "Bamenda", "Yaounde", "Douala", "Limbe" ] },
  { name: "Garanti", branches: [ "Bamenda", "Yaounde", "Douala", "Limbe" ] },
  { name: "Golden", branches: [ "Kumba", "Buea", "Douala" ] }
]

def create_agencies_and_branches
  AGENCIES.each_with_index do |details, idx|
    password = "password"
    agency = Agency.create!(name: details[:name])

    ActsAsTenant.with_tenant(agency) do
      details[:branches].each_with_index do |name, idx|
        branch = agency.branches.create!(name:, telephone: "6203098#{agency.id}#{idx}")
        telephone = "67#{(branch.id.to_s + idx.to_s).rjust(3, "0")}5621"
        agency.managers.create!(full_name: "#{details[:name]} Admin", telephone:, password:,
                                password_confirmation: password, confirmed: true, role: :manager, branch:)
        # Create 3 operators for each branch
        3.times do |n|
          telephone = "65249#{(branch.id.to_s + idx.to_s + n.to_s).rjust(4, "0")}"
          branch.operators.create!(full_name: "#{details[:name]}-#{name} Operator-#{n + 1}",
                                    telephone:, password:, password_confirmation: password,
                                    confirmed: true, role: :operator, branch:)
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

  Agency.all.each do |agency|
    ActsAsTenant.with_tenant(agency) do
      branch_ids = agency.branch_ids
      agency.branches.each do |branch|
        # create 10 deliveries for each branch
        operator_ids = branch.operator_ids

        10.times do
          sender_id, receiver_id, = customer_ids.shuffle[3, 7]
          destination_id = branch_ids.select { |id| id != branch.id }.shuffle.sample
          registered_by_id = operator_ids.shuffle.sample

          attrs =  { sender_id:, receiver_id:, origin_id: branch.id, destination_id:, registered_by_id: }

          sleep 1 # Avoid creating tracking number within thesame second
          Delivery.create!(attrs)
        end
      end
    end
  end
end


ActiveRecord::Base.transaction do
  p "Creating Agencies and Branches"
  create_agencies_and_branches
  p "Create customers and deliveries"
  create_customers_and_deliveries
end
