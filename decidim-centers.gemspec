# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/centers/version"

Gem::Specification.new do |s|
  s.version = Decidim::Centers.version
  s.authors = ["Francisco Bolívar"]
  s.email = ["francisco.bolivar@nazaries.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-centers"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-centers"
  s.summary = "A decidim centers module"
  s.description = "Manage your centers and scopes so the users can be authorized over them."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Centers.version
end
