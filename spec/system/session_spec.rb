require 'rails_helper'

RSpec.describe "User Session", type: :system do
  let!(:enterprise) { create(:enterprise) }
  let!(:enterprises) { create_list(:enterprise, 5) }
  let!(:user) { create(:admin, :manager, :confirmed, enterprise:) }

  describe "login" do
    it 'displays flash error with wrong user credential' do
      visit login_path(params: { enterprise_name: enterprise.name })
      fill_in "telephone", with: user.telephone
      fill_in "password", with: 'a wrong password'
      find("input[type='submit']").click

      expect(page).to have_current_path(login_path(params: { enterprise_name: enterprise.name }))
      expect(page).to have_content(/Wrong telephone number or password./)
    end

    it 'signs in user and redirect to root path' do
      visit login_path(params: { enterprise_name: enterprise.name })
      fill_in "telephone", with: user.telephone
      fill_in "password", with: user.password
      find("input[type='submit']").click

      expect(page).to have_current_path(deliveries_path)
      expect(page).to have_no_content(/Wrong telephone number or password./)
    end

    it "redirects to root when enterprise is not set" do
      visit deliveries_path
      expect(page).to have_current_path(root_path)
      expect(page).to have_content(/Please select an enterprise to login/)
      enterprises.each do |enterprise|
        expect(page).to have_content(enterprise.name)
      end
    end

    it "redirects to login path for enterprise name" do
      enterprises.each do |enterprise|
        visit root_path
        click_link enterprise.name

        expect(page).to have_content(/You need to sign in to continue/)
        expect(page).to have_current_path(login_path(params: { enterprise_name: enterprise.name }))
      end
    end

    it "fails to login user with incorrect enterprise" do
      manager = create(:admin, :confirmed, :manager, enterprise: enterprises.first)

      visit login_path(params: { enterprise_name: enterprise.name })
      fill_in "telephone", with: manager.telephone
      fill_in "password", with: manager.password
      find("input[type='submit']").click

      expect(page).to have_current_path(login_path(params: { enterprise_name: enterprise.name }))
      expect(page).to have_content(/Wrong telephone number or password./)
    end
  end

  describe "logout" do
    it 'logs out sign in user' do
      sign_in(user)
      visit account_path

      click_button "Log out"
      expect(page).to have_current_path(login_path(params: { enterprise_name: user.enterprise.name }))
    end
  end
end
