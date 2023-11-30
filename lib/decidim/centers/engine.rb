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

      initializer "Centers.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
