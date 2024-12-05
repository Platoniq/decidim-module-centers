# frozen_string_literal: true

require "spec_helper"

describe "Admin manages roles", type: :system do
  let(:organization) { create :organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
  end

  def visit_roles_path
    visit decidim_admin_centers.roles_path
  end

  def visit_edit_role_path(role)
    visit decidim_admin_centers.edit_role_path(role)
  end

  it "renders the expected menu" do
    within ".main-nav" do
      expect(page).to have_content("Roles")
    end

    click_link "Roles"

    expect(page).to have_content("Roles")
  end

  context "when visiting roles path" do
    before do
      visit_roles_path
    end

    it "shows new role button" do
      expect(page).to have_content("New role")
    end

    context "when no roles created" do
      it "shows an empty table" do
        expect(page).to have_no_selector("table.table-list.roles tbody tr")
      end
    end

    context "when roles created" do
      let!(:roles) { create_list :role, 5, organization: organization }
      let(:role) { roles.first }

      before do
        visit_roles_path
      end

      it "shows table rows" do
        expect(page).to have_selector("table.table-list.roles tbody tr", count: 5)
      end

      it "shows all the roles" do
        roles.each do |role|
          expect(page).to have_content(role.title["en"])
        end
      end

      it "can create role and show the action in the admin log" do
        find(".card-title a.button").click

        fill_in_i18n(
          :role_title,
          "#role-title-tabs",
          en: "My role"
        )

        within ".new_role" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_content("My role")
        end

        click_link "Dashboard"

        expect(page).to have_content("created the My role role")
      end

      it "cannot create an invalid role" do
        find(".card-title a.button").click

        within ".new_role" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("problem")
      end

      it "can edit role and show the action in the admin log" do
        within find("tr", text: translated(role.title)) do
          click_link "Edit"
        end

        fill_in_i18n(
          :role_title,
          "#role-title-tabs",
          en: "My edited role"
        )

        within ".edit_role" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_content("My edited role")

        click_link "Dashboard"

        expect(page).to have_content("updated the My edited role role")
      end

      it "cannot save an edited invalid role" do
        within find("tr", text: translated(role.title)) do
          click_link "Edit"
        end

        fill_in_i18n(
          :role_title,
          "#role-title-tabs",
          en: ""
        )

        within ".edit_role" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("problem")
      end

      it "can delete role" do
        within find("tr", text: translated(role.title)) do
          accept_confirm { click_link "Delete" }
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_no_content(translated(role.title))
          expect(page).to have_selector("table.table-list.roles tbody tr", count: 4)
        end
      end

      context "when role from other organization" do
        let(:other_organization) { create :organization }
        let!(:role) { create :role, organization: other_organization }

        it "does not show the it" do
          visit_roles_path

          expect(page).not_to have_content(role.title["en"])
        end
      end
    end
  end
end
