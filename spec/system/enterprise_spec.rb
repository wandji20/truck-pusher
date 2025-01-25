require 'rails_helper'

RSpec.describe "Enterprises", type: :system do
  let!(:enterprise) { create(:enterprise) }
  let!(:branches) { create_list(:branch, 5, enterprise:) }
  let!(:user) { create(:admin, :manager, :confirmed, enterprise:, branch: branches.first) }

  describe 'manage branch' do
    before(:each) do
      sign_in(user)
      visit enterprise_setting_path
    end

    it 'list branches' do
      branches.each_with_index do |branch|
        expect(page).to have_content(branch.name)
      end
    end

    it "creates new branch" do
      click_button "Add branch"
      expect(page).to have_content("Create new branch for #{enterprise.name}")

      within "#new-branch" do
        # Fill invalid values
        fill_in "branch[name]", with: "N"
        fill_in "branch[telephone]", with: "3"
        find("input[type='submit']").click

        expect(page).to have_content("is too short (minimum is 2 characters)")
        expect(page).to have_content("is invalid")

        # Fill correct values
        fill_in "branch[name]", with: "New Branch"
        fill_in "branch[telephone]", with: "678965412"
        find("input[type='submit']").click
      end
      expect(page).to have_no_css("#new-branch")
      expect(page).to have_no_content("is too short (minimum is 2 characters)")
      expect(page).to have_no_content("is invalid")
    end

    it "edits existing branch name" do
      branch = branches.first

      expect(page).to have_content(branch.name)

      within "tr#branch_#{branch.id}" do
        click_button "Edit"
      end

      expect(page).to have_content("Edit branch for #{enterprise.name}")

      within "#edit_branch_#{branch.id}" do
        # Fill invalid values
        fill_in "branch[name]", with: "e"
        fill_in "branch[telephone]", with: "4"
        find("input[type='submit']").click

        expect(page).to have_content("is too short (minimum is 2 characters)")
        expect(page).to have_content("is invalid")

        # Fill correct values
        fill_in "branch[name]", with: "Branch Name updated"
        fill_in "branch[telephone]", with: "670000412"
        find("input[type='submit']").click
      end
      expect(page).to have_no_css("#edit_branch_#{branch.id}")

      within "tr#branch_#{branch.id}" do
        expect(page).to have_content("Branch Name updated")
      end
    end
  end

  describe "manage users" do
    let!(:users) { create_list(:admin, 10, :operator, :confirmed, enterprise:, branch: branches.first) }

    before(:each) do
      sign_in(user)
      visit enterprise_setting_path(params: { option: "users" })
    end

    it "list and removes user" do
      users.each do |user|
        expect(page).to have_content(user.full_name)
        expect(page).to have_content(user.telephone)
      end

      user = users.first
      within "tr#users_admin_#{user.id}" do
        click_button("Remove")
        accept_confirm
      end

      expect(page).to have_no_css("tr#users_admin_#{user.id}")
    end
  end
end
