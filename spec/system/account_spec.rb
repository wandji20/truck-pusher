require 'rails_helper'

RSpec.describe "User Account", type: :system do
  let!(:user) { create(:admin, :manager, :confirmed) }

  describe 'account update' do
    before(:each) do
      sign_in(user)
      visit account_path
    end

    it 'updates user name' do
      expect(find("input[name='users_admin[full_name]']").value).to eq(user.full_name)
      # Input invalid full name
      fill_in 'users_admin[full_name]', with: 's'
      find("input[type='submit']").click
      expect(page).to have_content(/is too short \(minimum is 2 characters\)/)

      # Input valid name
      fill_in 'users_admin[full_name]', with: 'New name'
      find("input[type='submit']").click

      expect(find("input[name='users_admin[full_name]']").value).to eq('New name')
      user.reload
      expect(user.full_name).to eq("New name")
      expect(page).to have_content(/Account successfully updated!/)
    end
  end
end
