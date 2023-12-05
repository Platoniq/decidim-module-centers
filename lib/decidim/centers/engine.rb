# frozen_string_literal: true

require "rails"
require "decidim/core"
require "deface"

module Decidim
  module Centers
    # This is the engine that runs on the public interface of centers.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Centers

      routes do
        # Add engine routes here
        # resources :centers
        # root to: "centers#index"
      end

      config.to_prepare do
        # commands
        Decidim::CreateOmniauthRegistration.prepend(Decidim::Centers::CreateOmniauthRegistrationOverride)
        Decidim::CreateRegistration.prepend(Decidim::Centers::CreateRegistrationOverride)
        Decidim::UpdateAccount.prepend(Decidim::Centers::UpdateAccountOverride)
        # forms
        Decidim::RegistrationForm.include(Decidim::Centers::AccountFormOverride)
        Decidim::OmniauthRegistrationForm.include(Decidim::Centers::AccountFormOverride)
        Decidim::AccountForm.include(Decidim::Centers::AccountFormOverride)
        # models
        Decidim::User.include(Decidim::Centers::UserOverride)
        Decidim::RegistrationForm.include(Centers::AccountFormOverride)
        Decidim::OmniauthRegistrationForm.include(Centers::AccountFormOverride)
        Decidim::AccountForm.include(Centers::AccountFormOverride)
        Decidim::CreateOmniauthRegistration.prepend(Centers::CreateOmniauthRegistrationOverride)
        Decidim::CreateRegistration.prepend(Centers::CreateRegistrationOverride)
        Decidim::UpdateAccount.prepend(Centers::UpdateAccountOverride)
      end

      initializer "decidim_centers.sync" do
        ActiveSupport::Notifications.subscribe "decidim.centers.user.updated" do |_name, data|
          Decidim::Centers::SyncCenterUserJob.perform_later(data)
        end
      end

      initializer "decidim_centers.overrides", after: "decidim.action_controller" do
        config.to_prepare do
          Decidim::Admin::ResourcePermissionsController.include(Decidim::Centers::Admin::NeedsSelect2Snippets)
          Decidim::Devise::SessionsController.include(Decidim::Centers::Devise::SessionsControllerOverride)
          Decidim::Devise::OmniauthRegistrationsController.include(Decidim::Centers::Devise::OmniauthRegistrationsControllerOverride)
        end
      end

      initializer "decidim_centers.sync" do
        ActiveSupport::Notifications.subscribe "decidim.centers.user.updated" do |_name, data|
          Decidim::Centers::SyncCenterUserJob.perform_now(data)
          Decidim::Centers::AutoVerificationJob.perform_later(data[:user_id])
        end
      end

      initializer "decidim_centers.authorizations" do
        Decidim::Verifications.register_workflow(:center) do |workflow|
          workflow.form = "Decidim::Centers::Verifications::Center"
          workflow.action_authorizer = "Decidim::Centers::Verifications::CenterActionAuthorizer"

          workflow.options do |options|
            options.attribute :centers, type: :string
          end
        end
      end

      initializer "decidim_centers.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
