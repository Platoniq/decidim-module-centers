# frozen_string_literal: true

require "spec_helper"

describe "Admin manages centers", type: :system do
  let(:organization) { create :organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
  end

  def visit_centers_path
    visit decidim_admin_centers.centers_path
  end

  def visit_edit_center_path(center)
    visit decidim_admin_centers.edit_center_path(center)
  end

  it "renders the expected menu" do
    within ".main-nav" do
      expect(page).to have_content("Centers")
    end

    click_link "Centers"

    expect(page).to have_content("Centers")
  end

  context "when visiting centers path" do
    before do
      visit_centers_path
    end

    it "shows new center button" do
      expect(page).to have_content("New center")
    end

    context "when no centers created" do
      it "shows an empty table" do
        expect(page).to have_no_selector("table.table-list.centers tbody tr")
      end
    end

    context "when centers created" do
      let!(:centers) { create_list :center, 5, organization: organization }
      let(:center) { centers.first }

      before do
        visit_centers_path
      end

      it "shows table rows" do
        expect(page).to have_selector("table.table-list.centers tbody tr", count: 5)
      end

      it "shows all the centers" do
        centers.each do |center|
          expect(page).to have_content(center.title["en"])
        end
      end

      it "can create center and show the action in the admin log" do
        find(".card-title a.button").click

        fill_in_i18n(
          :center_title,
          "#center-title-tabs",
          en: "My center"
        )

        within ".new_center" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_content("My center")
        end

        click_link "Dashboard"

        expect(page).to have_content("created the My center center")
      end

      it "cannot create an invalid center" do
        find(".card-title a.button").click

        within ".new_center" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("problem")
      end

      it "can edit center and show the action in the admin log" do
        within find("tr", text: translated(center.title)) do
          click_link "Edit"
        end

        fill_in_i18n(
          :center_title,
          "#center-title-tabs",
          en: "My edited center"
        )

        within ".edit_center" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_content("My edited center")

        click_link "Dashboard"

        expect(page).to have_content("updated the My edited center center")
      end

      it "cannot save an edited invalid center" do
        within find("tr", text: translated(center.title)) do
          click_link "Edit"
        end

        fill_in_i18n(
          :center_title,
          "#center-title-tabs",
          en: ""
        )

        within ".edit_center" do
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("problem")
      end

      it "can delete center" do
        within find("tr", text: translated(center.title)) do
          accept_confirm { click_link "Delete" }
        end

        expect(page).to have_admin_callout("successfully")

        within "table" do
          expect(page).to have_no_content(translated(center.title))
          expect(page).to have_selector("table.table-list.centers tbody tr", count: 4)
        end
      end

      context "when center from other organization" do
        let(:other_organization) { create :organization }
        let!(:center) { create :center, organization: other_organization }

        it "does not show the it" do
          visit_centers_path

          expect(page).not_to have_content(center.title["en"])
        end
      end
    end
  end
end
