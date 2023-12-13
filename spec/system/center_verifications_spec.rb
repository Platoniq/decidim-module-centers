# frozen_string_literal: true

require "spec_helper"
require "decidim/centers/test/shared_contexts"
require "decidim/proposals/test/factories"

describe "Center verifications spec", type: :system do
  let(:options) { {} }
  let!(:organization) { create :organization, available_authorizations: %w(center) }
  let(:participatory_process) { create :participatory_process, :with_steps, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let!(:proposal) { create :proposal, component: component }
  let!(:component) { create :proposal_component, :with_creation_enabled, participatory_space: participatory_process }
  let!(:centers) { create_list :center, 10, organization: organization }
  let!(:scopes) { create_list :scope, 10, organization: organization }
  let(:center) { centers.first }
  let(:other_center) { centers.second }
  let(:another_center) { centers.last }
  let(:scope) { scopes.first }
  let(:other_scope) { scopes.second }
  let(:another_scope) { scopes.last }
  let!(:authorization) { create(:authorization, :granted, user: user, name: "center", metadata: { "centers" => [center.id], "scopes" => [scope.id] }) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    permissions = {
      create: {
        authorization_handlers: {
          "center" => { "options" => options }
        }
      }
    }
    component.update!(permissions: permissions)

    visit main_component_path(component)
    click_link "New proposal"
  end

  after do
    expect_no_js_errors
  end

  shared_examples "user is authorized" do
    it do
      expect(page).to have_content "Create your proposal"
      expect(page).to have_selector ".new_proposal"
    end
  end

  shared_examples "user is authorized with wrong metadata" do
    it do
      expect(page).to have_content "Not authorized"
      expect(page).to have_content "you can't perform this action"
      expect(page).not_to have_content "Create your proposal"
    end
  end

  shared_examples "user is not authorized" do
    it do
      expect(page).to have_link "Authorize"
      expect(page).to have_content "you need to be authorized"
    end
  end

  context "when scopes are disabled" do
    include_context "with scopes disabled"

    let!(:authorization) { create(:authorization, :granted, user: user, name: "center", metadata: { "centers" => [center.id] }) }

    context "with no centers specified" do
      let(:options) { {} }

      it_behaves_like "user is authorized"

      context "when no authorization" do
        let!(:authorization) { nil }

        it_behaves_like "user is not authorized"
      end
    end

    context "with centers specified" do
      context "when the user has one of the specified centers" do
        let(:options) { { "centers" => "#{center.id},#{other_center.id}" } }

        it_behaves_like "user is authorized"
      end

      context "when the user doesn't have one of the specified centers" do
        let(:options) { { "centers" => "#{other_center.id},#{another_center.id}" } }

        it_behaves_like "user is authorized with wrong metadata"
      end
    end
  end

  context "when scopes are enabled" do
    context "with no centers specified" do
      context "with no scopes specified" do
        let(:options) { {} }

        it_behaves_like "user is authorized"

        context "when no authorization" do
          let!(:authorization) { nil }

          it_behaves_like "user is not authorized"
        end
      end

      context "with scopes specified" do
        let(:options) { { "scopes" => "#{scope.id},#{other_scope.id}" } }

        it_behaves_like "user is authorized"
      end

      context "when the user doesn't have one of the specified scopes" do
        let(:options) { { "scopes" => "#{other_scope.id},#{another_scope.id}" } }

        it_behaves_like "user is authorized with wrong metadata"
      end
    end

    context "with centers specified" do
      context "with no scopes specified" do
        context "when the user has one of the specified centers" do
          let(:options) { { "centers" => "#{center.id},#{other_center.id}" } }

          it_behaves_like "user is authorized"
        end

        context "when the user doesn't have one of the specified centers" do
          let(:options) { { "centers" => "#{other_center.id},#{another_center.id}" } }

          it_behaves_like "user is authorized with wrong metadata"
        end
      end

      context "with scopes specified" do
        context "when the user has one of the specified centers and scopes" do
          let(:options) { { "centers" => "#{center.id},#{other_center.id}", "scopes" => "#{scope.id},#{other_scope.id}" } }

          it_behaves_like "user is authorized"
        end

        context "when the user doesn't have one of the specified centers" do
          let(:options) { { "centers" => "#{other_center.id},#{another_center.id}", "scopes" => "#{scope.id},#{other_scope.id}" } }

          it_behaves_like "user is authorized with wrong metadata"
        end

        context "when the user doesn't have one of the specified scopes" do
          let(:options) { { "centers" => "#{center.id},#{other_center.id}", "scopes" => "#{other_scope.id},#{another_scope.id}" } }

          it_behaves_like "user is authorized with wrong metadata"
        end

        context "when the user doesn't have one of the centers specified neither the scope" do
          let(:options) { { "centers" => "#{other_center.id},#{another_center.id}", "scopes" => "#{other_scope.id},#{another_scope.id}" } }

          it_behaves_like "user is authorized with wrong metadata"
        end
      end
    end
  end

  def visit_proposal
    page.visit resource_locator(proposal).path
  end
end
