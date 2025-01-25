require 'rails_helper'

RSpec.describe "User Password", type: :system do
  let(:enterprise) { create(:enterprise) }
  let!(:user) { create(:admin, :manager, :confirmed, enterprise:) }

  describe "password reset" do
    it 'redirects to root path with wrong telephone' do
      visit login_path(params: { enterprise_name: enterprise.name })
      click_link("Forgot Password?")

      expect(page).to have_current_path(new_password_path(params: { enterprise_name: enterprise.name }))
      fill_in "telephone", with: '36547'
      find("input[type='submit']").click

      expect(page).to have_current_path(root_path)
      expect(page).to have_content(/Telephone number not found!/)
    end

    it 'creates reset link and redirect to root path' do
      visit login_path(params: { enterprise_name: enterprise.name })
      click_link("Forgot Password?")

      expect(page).to have_current_path(new_password_path(params: { enterprise_name: enterprise.name }))
      fill_in "telephone", with: user.telephone
      find("input[type='submit']").click

      expect(page).to have_current_path(root_path)
      expect(page).to have_content(/Password reset instructions successfully sent./)
    end

    it 'saves new password and redirect to login path' do
      visit login_path(params: { enterprise_name: enterprise.name })
      click_link("Forgot Password?")

      expect(page).to have_current_path(new_password_path(params: { enterprise_name: enterprise.name }))
      fill_in "telephone", with: user.telephone
      find("input[type='submit']").click

      expect(page).to have_current_path(root_path)
      expect(page).to have_content(/Password reset instructions successfully sent./)

      # Fill invalid password and password confirmation
      token = user.password_reset_token
      visit edit_password_path(token, params: { enterprise_name: enterprise.name })
      fill_in "Password", with: 'password'
      fill_in "Password confirmation", with: 'passworda'
      find("input[type='submit']").click

      expect(page).to have_current_path(edit_password_path(token, params: { enterprise_name: enterprise.name }))
      expect(page).to have_content(/doesn't match Password/)

      # Now fill correct password and confirmation
      fill_in "Password", with: 'password'
      fill_in "Password confirmation", with: 'password'
      find("input[type='submit']").click
      expect(page).to have_current_path(login_path(params: { enterprise_name: enterprise.name }))
      expect(page).to have_content(/Password has been successfully reset./)
    end
  end
end
