# frozen_string_literal: true

require "spec_helper"
require "decidim/centers/test/shared_contexts"

describe "Account", type: :system do
  let(:organization) { create :organization }
  let(:user) { create :user, :confirmed, organization: organization }
  let!(:center) { create :center, organization: organization }
  let!(:other_center) { create :center, organization: organization }
  let!(:role) { create :role, organization: organization }
  let!(:other_role) { create :role, organization: organization }
  let!(:scope) { create :scope, organization: organization }
  let!(:other_scope) { create :scope, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_context "when visiting account path" do
    before do
      visit decidim.account_path
    end
  end

  shared_context "with authorization" do
    let!(:authorization) { create :authorization, name: "center", user: user, metadata: { centers: [center.id], roles: [role&.id].compact, scopes: [scope&.id].compact } }
  end

  shared_context "with user with center" do
    let!(:center_user) { create :center_user, center: center, user: user }

    include_context "when visiting account path"
  end

  shared_context "with user with role" do
    let!(:role_user) { create :role_user, role: role, user: user }

    include_context "when visiting account path"
  end

  shared_context "with user with scope" do
    let!(:scope_user) { create :scope_user, scope: scope, user: user }

    include_context "when visiting account path"
  end

  shared_examples_for "user without center changes the center" do
    it "shows an empty value on the center input" do
      expect(find("#user_center_id").value).to eq("")
    end

    include_examples "user changes the center"
  end

  shared_examples_for "user with center changes the center" do
    it "has an authorization for the center" do
      check_center_authorization(Decidim::Authorization.last, user, center)
    end

    it "shows the current center on the center input" do
      expect(find("#user_center_id").value).to eq(center.id.to_s)
    end

    include_examples "user changes the center"
  end

  shared_examples_for "user cannot be saved without changes" do
    it "cannot save without selecting center" do
      within "form.edit_user" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("There's an error in this field").or have_content("can't be blank")
    end
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

  shared_examples_for "user without role changes the role" do
    it "shows an empty value on the role input" do
      expect(find("#user_role_id").value).to eq("")
    end

    include_examples "user changes the role", false
  end

  shared_examples_for "user with role changes the role" do
    it "has an authorization for the center and the role" do
      check_center_authorization(Decidim::Authorization.last, user, center, role: role)
    end

    it "shows the current role on the role input" do
      expect(find("#user_role_id").value).to eq(role.id.to_s)
    end

    include_examples "user changes the role", true
  end

  shared_examples_for "user changes the role" do
    it "can update the role and changes the authorization" do
      within "form.edit_user" do
        within "#user_role_id" do
          find("option[value='#{other_role.id}']").click
        end

        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      expect(find("#user_role_id").value).to eq(other_role.id.to_s)

      perform_enqueued_jobs
      check_center_authorization(Decidim::Authorization.last, user, center, role: other_role)
    end
  end

  shared_examples_for "user without scope changes the scope" do
    it "shows an empty value on the scope input" do
      within "#user_scope_id" do
        expect(page).to have_content("Global scope")
      end
    end

    include_examples "user changes the scope", false
  end

  shared_examples_for "user with scope changes the scope" do
    it "has an authorization for the center and the scope" do
      check_center_authorization(Decidim::Authorization.last, user, center, scope: scope)
    end

    it "shows the current scope on the scope input" do
      within "#user_scope_id" do
        expect(page).to have_content(scope.name["en"])
      end
    end

    include_examples "user changes the scope", true
  end

  shared_examples_for "user changes the scope" do |has_scope|
    it "can update the scope and changes the authorization" do
      within "form.edit_user" do
        if has_scope
          scope_repick :user_scope_id, scope, other_scope
        else
          scope_pick select_data_picker(:user_scope_id), other_scope
        end

        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      within "#user_scope_id .picker-values" do
        expect(page).to have_content(other_scope.name["en"])
      end

      perform_enqueued_jobs
      check_center_authorization(Decidim::Authorization.last, user, center, scope: other_scope)
    end
  end

  include_context "when visiting account path"

  context "when the roles and the scopes are disabled" do
    include_context "with roles disabled"
    include_context "with scopes disabled"
    include_context "when visiting account path"

    it "doesn't show the role input" do
      expect(page).not_to have_selector("#user_role_id")
      expect(page).not_to have_selector("#user_scope_id")
    end

    context "when the user doesn't have center" do
      include_examples "user cannot be saved without changes"
      include_examples "user without center changes the center"
    end

    context "when the user has center" do
      include_context "with user with center"
      include_context "with authorization"

      include_examples "user with center changes the center"
    end
  end

  context "when the roles are enabled and the scopes disabled" do
    include_context "with scopes disabled"
    include_context "when visiting account path"

    context "when the user doesn't have role" do
      context "when the user doesn't have center" do
        include_examples "user cannot be saved without changes"
      end

      context "when the user has center" do
        include_context "with user with center"
        include_context "with authorization"

        include_examples "user cannot be saved without changes"
        include_examples "user without role changes the role"
      end
    end

    context "when the user has role" do
      include_context "with user with role"

      context "when the user doesn't have center" do
        include_examples "user cannot be saved without changes"
      end

      context "when the user has center" do
        include_context "with user with center"
        include_context "with authorization"

        include_examples "user with role changes the role"
      end
    end
  end

  context "when the scopes are enabled and the roles disabled" do
    include_context "with roles disabled"
    include_context "when visiting account path"

    context "when the user doesn't have scope" do
      context "when the user doesn't have center" do
        include_examples "user cannot be saved without changes"
      end

      context "when the user has center" do
        include_context "with user with center"
        include_context "with authorization"

        include_examples "user cannot be saved without changes"
        include_examples "user without scope changes the scope"
      end
    end

    context "when the user has scope" do
      include_context "with user with scope"

      context "when the user doesn't have center" do
        include_examples "user cannot be saved without changes"
      end

      context "when the user has center" do
        include_context "with user with center"
        include_context "with authorization"

        include_examples "user with scope changes the scope"
      end
    end
  end

  context "when the roles and the scopes are enabled" do
    include_context "when visiting account path"

    context "when the user doesn't have role nor scope" do
      context "when the user doesn't have center" do
        include_examples "user cannot be saved without changes"
      end

      context "when the user has center" do
        include_context "with user with center"
        include_context "with authorization"

        include_examples "user cannot be saved without changes"
      end
    end

    context "when the user has role" do
      include_context "with user with role"

      context "when the user doesn't have center" do
        include_examples "user cannot be saved without changes"
      end

      context "when the user has center" do
        include_context "with user with center"
        include_context "with authorization"

        include_examples "user cannot be saved without changes"
        include_examples "user without scope changes the scope"
      end
    end

    context "when the user has scope" do
      include_context "with user with scope"

      context "when the user doesn't have center" do
        include_examples "user cannot be saved without changes"
      end

      context "when the user has center" do
        include_context "with user with center"
        include_context "with authorization"

        include_examples "user cannot be saved without changes"
        include_examples "user without role changes the role"
      end
    end

    context "when the user has role and scope" do
      include_context "with user with role"
      include_context "with user with scope"

      context "when the user doesn't have center" do
        include_examples "user cannot be saved without changes"
        include_examples "user without center changes the center"
      end

      context "when the user has center" do
        include_context "with user with center"
        include_context "with authorization"

        include_context "user with center changes the center"
        include_examples "user with scope changes the scope"
        include_examples "user with role changes the role"
      end
    end
  end
end
