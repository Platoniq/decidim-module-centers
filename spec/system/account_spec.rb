# frozen_string_literal: true

require "spec_helper"
require "decidim/centers/test/shared_contexts"

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
    it "can update the center and changes the authorization" do
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

      perform_enqueued_jobs
      check_center_authorization(Decidim::Authorization.last, user, other_center)
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
    let!(:authorization) { create :authorization, name: "center", user: user, metadata: { centers: [center.id] } }

    before do
      visit decidim.account_path
    end

    it "has an authorization for the center" do
      check_center_authorization(Decidim::Authorization.last, user, center)
    end

    it "shows the current center on the center input" do
      expect(find("#user_center_id").value).to eq(center.id.to_s)
    end

    include_examples "user changes the center"
  end
end
