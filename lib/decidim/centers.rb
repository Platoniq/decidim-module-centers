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
      true
    end
  end
end
