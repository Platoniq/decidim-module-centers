# frozen_string_literal: true

require "spec_helper"

describe "Admin manages component permissions", type: :system do
  let(:organization) { create :organization, available_authorizations: %w(center) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let!(:centers) { create_list :center, 10, organization: organization }
  let(:center) { centers.first }
  let(:other_center) { centers.second }
  let(:another_center) { centers.last }
  let(:participatory_space_engine) { decidim_admin_participatory_processes }
  let!(:component) { create :component, participatory_space: participatory_space }
  let!(:participatory_space) { create :participatory_process, organization: organization }
  let(:permissions) do
    {
      "foo" => {
        "authorization_handlers" => {
          "center" => {
            "options" => { "centers" => "#{center.id},#{other_center.id}" }
          }
        }
      }
    }
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit participatory_space_engine.components_path(participatory_space)
  end

  def select_center(name)
    within "form.new_component_permissions" do
      within ".foo-permission" do
        check "Center"
        fill_in "Centers", with: name
      end
    end

    find("li.select2-results__option", text: name).click
  end

  def unselect_center(name)
    find("li.select2-selection__choice[title=\"#{name}\"] button.select2-selection__choice__remove").click
  end

  def submit_form
    within "form.new_component_permissions" do
      find("*[type=submit]").click
    end
  end

  context "when setting permissions" do
    before do
      within ".component-#{component.id}" do
        click_link "Permissions"
      end
    end

    it "saves permission settings in the component" do
      within "form.new_component_permissions" do
        within ".foo-permission" do
          check "Center"
        end
      end

      select_center(center.title["en"])
      select_center(other_center.title["en"])
      submit_form

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to(
        include(
          "authorization_handlers" => {
            "center" => {
              "options" => { "centers" => "#{center.id},#{other_center.id}" }
            }
          }
        )
      )
    end
  end

  context "when unsetting permissions" do
    before do
      component.update!(permissions: permissions)

      within ".component-#{component.id}" do
        click_link "Permissions"
      end
    end

    it "removes the action from the permissions hash" do
      within "form.new_component_permissions" do
        within ".foo-permission" do
          uncheck "Center"
        end
      end

      submit_form

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to be_nil
    end
  end

  context "when changing existing permissions" do
    before do
      component.update!(permissions: permissions)

      within ".component-#{component.id}" do
        click_link "Permissions"
      end
    end

    it "changes the configured action in the permissions hash" do
      unselect_center(center.title["en"])
      select_center(another_center.title["en"])
      submit_form

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to(
        include(
          "authorization_handlers" => {
            "center" => {
              "options" => { "centers" => "#{other_center.id},#{another_center.id}" }
            }
          }
        )
      )
    end
  end
end
