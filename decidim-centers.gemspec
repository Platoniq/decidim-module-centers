# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/centers/version"

Gem::Specification.new do |s|
  s.version = Decidim::Centers::VERSION
  s.authors = ["Francisco Bolívar"]
  s.email = ["francisco.bolivar@nazaries.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-centers"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-centers"
  s.summary = "A decidim module to categorize users with centers and scopes"
  s.description = "Manage your centers and scopes so the users can be authorized over them."

  s.files = Dir["{app,config,lib,db}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Centers::COMPAT_DECIDIM_VERSION
  s.add_dependency "deface", "~> 1.9"
end
