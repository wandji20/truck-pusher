require 'rails_helper'

RSpec.describe "Marketer Account", type: :system do
  let!(:marketer) { create(:marketer, :confirmed) }

  describe 'account update' do
    before(:each) do
      sign_in_marketer(marketer)
      visit campaigns_account_path
    end

    it 'updates marketer name' do
      expect(find("input[name='marketer[full_name]']").value).to eq(marketer.full_name)
      # Input invalid full name
      fill_in 'marketer[full_name]', with: 's'
      find("input[type='submit']").click
      expect(page).to have_content(/is too short \(minimum is 2 characters\)/)

      # Input valid name
      fill_in 'marketer[full_name]', with: 'New name'
      find("input[type='submit']").click

      expect(find("input[name='marketer[full_name]']").value).to eq('New name')
      marketer.reload
      expect(marketer.full_name).to eq("New name")
      expect(page).to have_content(/Account successfully updated!/)
    end
  end
end
