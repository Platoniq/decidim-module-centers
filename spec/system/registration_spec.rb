# frozen_string_literal: true

require "spec_helper"
require "decidim/centers/test/shared_contexts"

describe "Registration spec", type: :system do
  let(:organization) { create :organization }
  let(:email) { Faker::Internet.email }
  let(:name) { Faker::Name.name }
  let(:nickname) { Faker::Internet.username(separators: []) }
  let(:password) { Faker::Internet.password(min_length: 17) }
  let!(:center) { create :center, organization: organization }
  let!(:other_center) { create :center, organization: organization }
  let!(:role) { create :role, organization: organization }
  let!(:other_role) { create :role, organization: organization }
  let!(:scope) { create :scope, organization: organization }
  let!(:other_scope) { create :scope, organization: organization }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  it "contains center field" do
    within ".card__centers" do
      expect(page).to have_content("Center")
    end
  end

  it "contains role field" do
    within ".card__centers" do
      expect(page).to have_content("Role")
    end
  end

  it "contains scope field" do
    within ".card__centers" do
      expect(page).to have_content("Scope")
    end
  end

  it "displays center as mandatory" do
    within ".card__centers label[for='registration_user_center_id']" do
      expect(page).to have_css("span.label-required")
    end
  end

  it "displays role as mandatory" do
    within ".card__centers label[for='registration_user_role_id']" do
      expect(page).to have_css("span.label-required")
    end
  end

  it "displays scope as mandatory" do
    within all(".card__centers label").last do
      expect(page).to have_css("span.label-required")
    end
  end

  it "allows to create a new account and authorizes the user with the center and scope provided" do
    fill_in :registration_user_name, with: name
    fill_in :registration_user_nickname, with: nickname
    fill_in :registration_user_email, with: email
    fill_in :registration_user_password, with: password
    fill_in :registration_user_password_confirmation, with: password

    within ".card__centers" do
      within "#registration_user_center_id" do
        find("option[value='#{center.id}']").click
      end

      within "#registration_user_role_id" do
        find("option[value='#{role.id}']").click
      end

      scope_pick select_data_picker(:registration_user), scope
    end

    page.check("registration_user_newsletter")
    page.check("registration_user_tos_agreement")

    within "form.new_user" do
      find("*[type=submit]").click
    end

    expect(page).to have_content("message with a confirmation link has been sent")
    expect(Decidim::User.last.center).to eq(center)
    expect(Decidim::User.last.role).to eq(role)
    expect(Decidim::User.last.scope).to eq(scope)

    perform_enqueued_jobs
    check_center_authorization(Decidim::Authorization.last, Decidim::User.last, center, scope: scope, role: role)
  end

  context "with scopes disabled" do
    include_context "with scopes disabled"

    before do
      visit decidim.new_user_registration_path
    end

    it "doesn't show the scope input" do
      expect(page).not_to have_content("Global scope")
    end

    it "doesn't show the role input" do
      expect(page).not_to have_content("Roles")
    end
  end
end
