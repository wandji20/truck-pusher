require 'rails_helper'

RSpec.describe "Marketer Session", type: :system do
  let!(:marketer) { create(:marketer, :confirmed) }

  describe "login" do
    it 'displays flash error with wrong marketer credential' do
      visit campaigns_login_path
      fill_in "email", with: marketer.email
      fill_in "password", with: 'a wrong password'
      find("input[type='submit']").click

      expect(page).to have_current_path(campaigns_login_path)
      expect(page).to have_content(/Wrong email or password./)
    end

    it 'signs in marketer and redirect to merchants path' do
      visit campaigns_login_path
      fill_in "email", with: marketer.email
      fill_in "password", with: marketer.password
      find("input[type='submit']").click

      expect(page).to have_current_path(campaigns_merchants_path)
      expect(page).to have_no_content(/Wrong email or password./)
    end
  end

  describe "logout" do
    it 'logs out sign in marketer' do
      sign_in_marketer(marketer)
      visit campaigns_account_path

      click_button "Log out"
      expect(page).to have_current_path(campaigns_login_path)
    end
  end
end
