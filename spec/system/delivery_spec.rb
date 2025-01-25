require 'rails_helper'

RSpec.describe "Deliveries", type: :system do
  context "Agency" do
    let!(:enterprise) { create(:enterprise) }
    let!(:branches) { create_list(:branch, 5, enterprise:) }
    let!(:user) { create(:admin, :manager, :confirmed, enterprise:, branch: branches.first) }
    let!(:deliveries) { create_list(:delivery, 20, enterprise:, origin: branches.first, destination: branches.third) }
    let!(:customers) { create_list(:customer, 20) }

    describe 'list and search' do
      before(:each) do
        sign_in(user)
      end

      it 'filters' do
        deliveries.each do |delivery|
          expect(page).to have_content(delivery.tracking_number)
          expect(page).to have_content(delivery.tracking_secret)
        end

        fill_in "search_deliveries", with: deliveries.first.tracking_secret

        deliveries.each_with_index do |delivery, idx|
          if idx == 0
            expect(page).to have_content(delivery.tracking_secret)
          else
            expect(page).to have_no_content(delivery.tracking_secret)
          end
        end
      end

      it "confirms deliveries" do
        within "tr#delivery_#{deliveries.first.id}" do
          expect(page).to have_content("Check in")
          expect(page).to have_no_content("Deliver")
          click_button "Check in"

          expect(page).to have_no_content("Check in")
          expect(page).to have_content("Deliver")

          click_button "Deliver"

          expect(page).to have_no_content("Check in")
          expect(page).to have_content("Delivered")
        end
      end
    end

    describe "new delivery" do
      before(:each) do
        sign_in(user)
        visit new_delivery_path
      end

      it "creates new delivery with for existing customers" do
        within "#delivery_destination_id" do
          click_button
          check branches.second.name
        end

        within "#delivery_sender_id" do
          click_button
          fill_in 'search', with: customers.first.telephone
          check customers.first.full_name
        end

        within "#delivery_receiver_id" do
          click_button
          fill_in 'search', with: customers.second.telephone
          check customers.second.full_name
        end

        find("input[type='submit']").click

        expect(page).to have_current_path(deliveries_path)
      end

      it "creates new delivery with for new customers" do
        sender = build(:customer)
        receiver = build(:customer)

        within "#delivery_destination_id" do
          click_button
          check branches.second.name
        end

        within "#delivery_sender_id" do
          click_button
          fill_in 'search', with: sender.telephone
          check "+ Add customer (#{sender.telephone})"
          fill_in "sender[full_name]", with: sender.full_name
        end

        within "#delivery_receiver_id" do
          click_button
          fill_in 'search', with: receiver.telephone
          check "+ Add customer (#{receiver.telephone})"
          fill_in "receiver[full_name]", with: receiver.full_name
        end

        fill_in "delivery[description]", with: "Test description"

        find("input[type='submit']").click

        expect(page).to have_current_path(deliveries_path)
      end

      it "displays errors for invalid values" do
        sender = build(:customer)
        receiver = build(:customer)

        find("input[type='submit']").click

        within "#delivery_destination_id" do
          expect(page).to have_content("must exist")
        end

        within "#delivery_sender_id" do
          expect(page).to have_content("can't be blank")
        end

        within "#delivery_receiver_id" do
          expect(page).to have_content("must exist")
        end

        expect(page).to have_current_path(new_delivery_path)

        # Now open new customer form

        within "#delivery_sender_id" do
          click_button
          fill_in 'search', with: sender.telephone
          check "+ Add customer (#{sender.telephone})"
        end

        within "#delivery_receiver_id" do
          click_button
          fill_in 'search', with: receiver.telephone
          check "+ Add customer (#{receiver.telephone})"
          fill_in "receiver[telephone]", with: "00"
        end

        find("input[type='submit']").click

        within "#delivery_sender_id" do
          expect(page).to have_content("is too short (minimum is 2 characters)")
        end

        within "#delivery_receiver_id" do
          expect(page).to have_content("is too short (minimum is 2 characters)")
          expect(page).to have_content("is invalid")
        end
      end
    end
  end

  context "Truck pusher" do
    let!(:enterprise) { create(:enterprise, category: 1) }
    let!(:branches) { create_list(:branch, 5, enterprise:) }
    let!(:user) { create(:admin, :manager, :confirmed, enterprise:, branch: branches.first) }
    let!(:deliveries) { create_list(:delivery, 20, enterprise:, origin: branches.first, destination: branches.third) }
    let!(:customers) { create_list(:customer, 20) }

    describe 'list and search' do
      before(:each) do
        sign_in(user)
      end

      it 'filters' do
        deliveries.each do |delivery|
          expect(page).to have_content(delivery.tracking_number)
          expect(page).to have_content(delivery.tracking_secret)
        end

        fill_in "search_deliveries", with: deliveries.first.tracking_secret

        deliveries.each_with_index do |delivery, idx|
          if idx == 0
            expect(page).to have_content(delivery.tracking_secret)
          else
            expect(page).to have_no_content(delivery.tracking_secret)
          end
        end
      end

      it "confirms deliveries" do
        within "tr#delivery_#{deliveries.first.id}" do
          expect(page).to have_content("Check in")
          expect(page).to have_no_content("Deliver")
          click_button "Check in"

          expect(page).to have_no_content("Check in")
          expect(page).to have_content("Deliver")

          click_button "Deliver"

          expect(page).to have_no_content("Check in")
          expect(page).to have_content("Delivered")
        end
      end
    end

    describe "new delivery" do
      before(:each) do
        sign_in(user)
        visit new_delivery_path
      end

      it "creates new delivery with for existing customers" do
        within "#delivery_destination_id" do
          click_button
          check branches.second.name
        end

        within "#delivery_sender_id" do
          click_button
          fill_in 'search', with: customers.first.telephone
          check customers.first.full_name
        end

        within "#delivery_receiver_id" do
          click_button
          fill_in 'search', with: customers.second.telephone
          check customers.second.full_name
        end

        find("input[type='submit']").click

        expect(page).to have_current_path(deliveries_path)
      end

      it "creates new delivery with for new customers" do
        sender = build(:customer)
        receiver = build(:customer)

        within "#delivery_destination_id" do
          click_button
          check branches.second.name
        end

        within "#delivery_sender_id" do
          click_button
          fill_in 'search', with: sender.telephone
          check "+ Add customer (#{sender.telephone})"
          fill_in "sender[full_name]", with: sender.full_name
        end

        within "#delivery_receiver_id" do
          click_button
          fill_in 'search', with: receiver.telephone
          check "+ Add customer (#{receiver.telephone})"
          fill_in "receiver[full_name]", with: receiver.full_name
        end

        fill_in "delivery[description]", with: "Test description"

        find("input[type='submit']").click

        expect(page).to have_current_path(deliveries_path)
      end

      it "displays errors for invalid values" do
        sender = build(:customer)
        receiver = build(:customer)

        find("input[type='submit']").click

        within "#delivery_destination_id" do
          expect(page).to have_content("must exist")
        end

        within "#delivery_sender_id" do
          expect(page).to have_content("can't be blank")
        end

        within "#delivery_receiver_id" do
          expect(page).to have_content("must exist")
        end

        expect(page).to have_current_path(new_delivery_path)

        # Now open new customer form

        within "#delivery_sender_id" do
          click_button
          fill_in 'search', with: sender.telephone
          check "+ Add customer (#{sender.telephone})"
        end

        within "#delivery_receiver_id" do
          click_button
          fill_in 'search', with: receiver.telephone
          check "+ Add customer (#{receiver.telephone})"
          fill_in "receiver[telephone]", with: "00"
        end

        find("input[type='submit']").click

        within "#delivery_sender_id" do
          expect(page).to have_content("is too short (minimum is 2 characters)")
        end

        within "#delivery_receiver_id" do
          expect(page).to have_content("is too short (minimum is 2 characters)")
          expect(page).to have_content("is invalid")
        end
      end
    end
  end

  context "Merchant" do
    let!(:enterprise) { create(:enterprise, :merchant) }
    let!(:branches) { create_list(:branch, 5, enterprise:) }
    let!(:user) { create(:admin, :manager, :confirmed, enterprise:, branch: branches.first) }
    let!(:deliveries) { create_list(:delivery, 20, enterprise:, destination: branches.third) }
    let!(:customers) { create_list(:customer, 20) }

    describe 'list and search' do
      before(:each) do
        sign_in(user)
      end

      it 'filters' do
        deliveries.each do |delivery|
          expect(page).to have_content(delivery.tracking_number)
          expect(page).to have_no_content(delivery.tracking_secret)
        end

        fill_in "search_deliveries", with: deliveries.first.tracking_secret

        deliveries.each_with_index do |delivery, idx|
          if idx == 0
            expect(page).to have_content(delivery.tracking_number)
          else
            expect(page).to have_no_content(delivery.tracking_secret)
          end
        end
      end

      it "has no confirm actions" do
        within "tr#delivery_#{deliveries.first.id}" do
          expect(page).to have_no_content("Check in")
          expect(page).to have_no_content("Deliver")

          expect(page).to have_content("Registered")
        end
      end
    end

    describe "new delivery" do
      before(:each) do
        sign_in(user)
        visit new_delivery_path
      end

      it "creates new delivery with for existing customers" do
        expect(page).to have_no_css("#delivery_sender_id")

        within "#delivery_destination_id" do
          click_button
          check branches.second.name
        end

        within "#delivery_receiver_id" do
          click_button
          fill_in 'search', with: customers.second.telephone
          check customers.second.full_name
        end

        find("input[type='submit']").click

        expect(page).to have_current_path(deliveries_path)
      end

      it "creates new delivery with for new customers" do
        receiver = build(:customer)

        within "#delivery_destination_id" do
          click_button
          check branches.second.name
        end

        within "#delivery_receiver_id" do
          click_button
          fill_in 'search', with: receiver.telephone
          check "+ Add customer (#{receiver.telephone})"
          fill_in "receiver[full_name]", with: receiver.full_name
        end

        fill_in "delivery[description]", with: "Test description"

        find("input[type='submit']").click

        expect(page).to have_current_path(deliveries_path)
      end

      it "displays errors for invalid values" do
        receiver = build(:customer)

        find("input[type='submit']").click

        within "#delivery_destination_id" do
          expect(page).to have_content("must exist")
        end

        within "#delivery_receiver_id" do
          expect(page).to have_content("must exist")
        end

        expect(page).to have_current_path(new_delivery_path)

        # Now open new customer form

        within "#delivery_receiver_id" do
          click_button
          fill_in 'search', with: receiver.telephone
          check "+ Add customer (#{receiver.telephone})"
          fill_in "receiver[telephone]", with: "00"
        end

        find("input[type='submit']").click

        within "#delivery_receiver_id" do
          expect(page).to have_content("is too short (minimum is 2 characters)")
          expect(page).to have_content("is invalid")
        end
      end
    end
  end
end
