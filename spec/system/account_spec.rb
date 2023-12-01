# frozen_string_literal: true

require "spec_helper"

describe "Account", type: :system do
  let(:organization) { create :organization }
  let(:user) { create :user, :confirmed, organization: organization }
  let!(:center) { create :center, organization: organization }
  let!(:other_center) { create :center, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples_for "user changes the center" do
    it "can update the center" do
      within "form.edit_user" do
        within "#user_center_id" do
          find("option[value='#{other_center.id}']").click
        end

        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      expect(find("#user_center_id").value).to eq(other_center.id.to_s)
    end
  end

  context "when the user doesn't have center" do
    before do
      visit decidim.account_path
    end

    it "shows an empty value on the center input" do
      expect(find("#user_center_id").value).to eq("")
    end

    include_examples "user changes the center"
  end

  context "when the user has center" do
    let!(:center_user) { create :center_user, center: center, user: user }

    before do
      visit decidim.account_path
    end

    it "shows the current center on the center input" do
      expect(find("#user_center_id").value).to eq(center.id.to_s)
    end

    include_examples "user changes the center"
  end
end
