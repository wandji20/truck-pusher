require 'rails_helper'

RSpec.describe "Merchants", type: :system do
  let!(:marketer) { create(:marketer, :confirmed) }
  let!(:merchants) { create_list(:enterprise, 10, :merchant, marketer:) }

  describe 'manage merchant' do
    before(:each) do
      sign_in_marketer(marketer)
    end

    it 'list merchants' do
      visit campaigns_merchants_path
      merchants.each_with_index do |merchant|
        expect(page).to have_content(merchant.name)
      end
    end

    it "creates new merchant" do
      visit new_campaigns_merchant_path

      expect(page).to have_content("New Merchant")

      within "#new_enterprise" do
        # Fill invalid values
        fill_in "enterprise[name]", with: "N"
        fill_in "enterprise[city]", with: "c"
        fill_in "enterprise[description]", with: "des"
        find("input[type='submit']").click

        expect(page).to have_current_path(new_campaigns_merchant_path)
        expect(page).to have_content("is too short (minimum is 2 characters)")
        expect(page).to have_content("is invalid")
        expect(page).to have_content("can't be blank")
        expect(page).to have_content("is too short (minimum is 6 characters)")

        # Fill correct values
        fill_in "enterprise[name]", with: "New Merchant"
        fill_in "enterprise[city]", with: "New City"
        fill_in "enterprise[description]", with: "description"
        fill_in "manager[telephone]", with: "632145789"
        find("input[type='submit']").click
      end

      expect(page).to have_no_content("is too short (minimum is 2 characters)")
      expect(page).to have_no_content("is invalid")
      expect(page).to have_no_content("can't be blank")
      expect(page).to have_no_content("is too short (minimum is 6 characters)")
    end

    it "edits existing merchant" do
      merchant = merchants.first

      within "#enterprise_#{merchant.id}" do
        click_link "Edit"
      end

      expect(page).to have_content("Edit Merchant")

      within "#edit_enterprise_#{merchant.id}" do
        fill_in "enterprise[name]", with: "Merchant name updated"
        fill_in "enterprise[city]", with: "City updated"
        fill_in "enterprise[description]", with: "description updated"

        find("input[type='submit']").click
      end

      expect(page).to have_content("Merchant name updated successfully updated!")
    end
  end
end
