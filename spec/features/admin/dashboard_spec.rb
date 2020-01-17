require 'rails_helper'

feature "Admin Dashboard", js: true do

  describe "Admin" do
    let(:admin) { FactoryBot.create(:user, :admin) }

    before do
      login_as(admin)
      visit admin_root_path
    end

    it "has admin links" do
      expect(page).to have_link("Manage Organizations")
      expect(page).to have_link("Manage Forms")
    end
  end

  describe "Organization Manager" do
    let(:organization_manager) { FactoryBot.create(:user, :organization_manager) }

    before do
      login_as(organization_manager)
      visit admin_root_path
    end

    it "does not have admin links" do
      expect(page).to_not have_link("Manage Organizations")
      expect(page).to_not have_link("Manage Form Templates")
    end

    it "has instructional text" do
      expect(page).to have_content("Create a Touchpoint")
      expect(page).to have_content("Update the Touchpoint's Form")
      expect(page).to have_content("Test the Form by creating a Submission")
    end
  end

  describe "Logged in User" do
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as(user)
      visit admin_root_path
    end

    it "does not have admin links" do
      expect(page).to_not have_link("Manage Organizations")
      expect(page).to_not have_link("Manage Form Templates")
    end

    it "has instructional text" do
      expect(page).to have_content("Create a Touchpoint")
      expect(page).to have_content("Update the Touchpoint's Form")
      expect(page).to have_content("Test the Form by creating a Submission")
    end
  end

  # Note:
  # Public users do not log in.
  # Logged in users are .gov users, but may not have permissions
  #  to edit any Services or other resources
  describe "non-privileged User" do
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as(user)
      visit admin_root_path
    end

    it "does not have admin links" do
      expect(page).to_not have_link("Manage Organizations")
      expect(page).to_not have_link("Manage Form Templates")
    end

    it "has instructional text" do
      expect(page).to have_content("Create a Touchpoint")
      expect(page).to have_content("Update the Touchpoint's Form")
      expect(page).to have_content("Test the Form by creating a Submission")
    end
  end

  describe "non logged-in User" do
    before do
      visit admin_root_path
    end

    it "redirected to home page and sees flash message" do
      expect(page.current_path).to eq(index_path)
      expect(page).to have_content("Authorization is Required")
    end
  end
end
