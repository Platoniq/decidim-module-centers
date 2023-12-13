# frozen_string_literal: true

require "spec_helper"
require "decidim/centers/test/shared_contexts"

describe "Admin manages component permissions", type: :system do
  let(:organization) { create :organization, available_authorizations: %w(center) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let!(:centers) { create_list :center, 10, organization: organization }
  let!(:scopes) { create_list :scope, 10, organization: organization }
  let(:center) { centers.first }
  let(:other_center) { centers.second }
  let(:another_center) { centers.last }
  let(:scope) { scopes.first }
  let(:other_scope) { scopes.second }
  let(:another_scope) { scopes.last }
  let(:participatory_space_engine) { decidim_admin_participatory_processes }
  let!(:component) { create :component, participatory_space: participatory_space }
  let!(:participatory_space) { create :participatory_process, organization: organization }
  let(:permissions) do
    {
      "foo" => {
        "authorization_handlers" => {
          "center" => {
            "options" => { "centers" => "#{center.id},#{other_center.id}", "scopes" => "#{scope.id},#{other_scope.id}" }
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

  def select_scope(name)
    within "form.new_component_permissions" do
      within ".foo-permission" do
        check "Center"
        fill_in "Scopes", with: name
      end
    end

    find("li.select2-results__option", text: name).click
  end

  def unselect_center(name)
    find(".centers_container li.select2-selection__choice[title=\"#{name}\"] button.select2-selection__choice__remove").click
  end

  def unselect_scope(name)
    find(".scopes_container li.select2-selection__choice[title=\"#{name}\"] button.select2-selection__choice__remove").click
  end

  def submit_form
    within "form.new_component_permissions" do
      find("*[type=submit]").click
    end
  end

  context "when scopes are disabled" do
    include_context "with scopes disabled"

    it "doesn't show a field for the scopes" do
      expect(page).not_to have_selector(".scopes_container")
    end
  end

  context "when setting permissions" do
    before do
      within ".component-#{component.id}" do
        click_link "Permissions"
      end
    end

    it "saves permission settings in the component" do
      select_center(center.title["en"])
      select_center(other_center.title["en"])
      select_scope(scope.name["en"])
      select_scope(other_scope.name["en"])
      submit_form

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to(
        include(
          "authorization_handlers" => {
            "center" => {
              "options" => { "centers" => "#{center.id},#{other_center.id}", "scopes" => "#{scope.id},#{other_scope.id}" }
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
      unselect_scope(scope.name["en"])
      select_scope(another_scope.name["en"])
      submit_form

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to(
        include(
          "authorization_handlers" => {
            "center" => {
              "options" => { "centers" => "#{other_center.id},#{another_center.id}", "scopes" => "#{other_scope.id},#{another_scope.id}" }
            }
          }
        )
      )
    end
  end
end
