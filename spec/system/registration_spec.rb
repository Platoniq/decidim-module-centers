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

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  it "contains center field" do
    within ".card__centers" do
      expect(page).to have_content("Center")
    end
  end

  it "displays center as mandatory" do
    within "label[for='registration_user_center_id']" do
      expect(page).to have_css("span.label-required")
    end
  end

  it "allows to create a new account and authorizes the user with the center provided" do
    fill_in :registration_user_name, with: name
    fill_in :registration_user_nickname, with: nickname
    fill_in :registration_user_email, with: email
    fill_in :registration_user_password, with: password
    fill_in :registration_user_password_confirmation, with: password

    within "#registration_user_center_id" do
      find("option[value='#{center.id}']").click
    end

    page.check("registration_user_newsletter")
    page.check("registration_user_tos_agreement")

    within "form.new_user" do
      find("*[type=submit]").click
    end

    expect(page).to have_content("message with a confirmation link has been sent")
    expect(Decidim::User.last.center).to eq(center)

    perform_enqueued_jobs
    check_center_authorization(Decidim::Authorization.last, Decidim::User.last, center)
  end
end
