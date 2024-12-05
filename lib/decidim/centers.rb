# frozen_string_literal: true

require "decidim/centers/admin"
require "decidim/centers/engine"
require "decidim/centers/admin_engine"
require "decidim/centers/verifications"

module Decidim
  # This namespace holds the logic of the `Centers` module. This module
  # allows users to create centers in a participatory space.
  module Centers
    include ActiveSupport::Configurable

    # if false, it won't ask the user for the scope
    config_accessor :scopes_enabled do
      Decidim::Env.new("DECIDIM_CENTERS_SCOPES_ENABLED", true).default_or_present_if_exists
    end

    # if false, it won't ask the user for the role
    config_accessor :roles_enabled do
      Decidim::Env.new("DECIDIM_CENTERS_ROLES_ENABLED", true).default_or_present_if_exists
    end
  end
end
