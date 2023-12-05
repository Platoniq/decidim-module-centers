# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-admin",
    files: {
      "/app/controllers/decidim/admin/resource_permissions_controller.rb" => "f3a204b0f85cc18556aadaa26ee68dc7"
    }
  },
  {
    package: "decidim-core",
    files: {
      "/app/commands/decidim/create_omniauth_registration.rb" => "586139f98ded0645eb83e480ef5dd6bd",
      "/app/commands/decidim/create_registration.rb" => "8bf3456d42c21036d08ccafe16e9105a",
      "/app/commands/decidim/update_account.rb" => "29d81617f5bf1af310d2777a916b4d8b",
      "/app/controllers/decidim/devise/omniauth_registrations_controller.rb" => "05bc35af4b5f855736f14efbd22e439b",
      "/app/controllers/decidim/devise/sessions_controller.rb" => "235cbe9844cdd39f65c72d3dc87f5f23",
      "/app/forms/decidim/account_form.rb" => "73a8150ed1620d515a1c96f680e98ec0",
      "/app/forms/decidim/omniauth_registration_form.rb" => "ee09e2b5675c9d1cb4dc955dded05393",
      "/app/forms/decidim/registration_form.rb" => "32b55eb5a1742b6b8ed7bbb4c7643dc0",
      "/app/models/decidim/user.rb" => "3d57a7c9130a91d44e1acd7475877b87",
      "/app/views/decidim/account/show.html.erb" => "567f47fd001a0222943579d9ebfe5f3a",
      "/app/views/decidim/devise/omniauth_registrations/new.html.erb" => "81d19863520eb70fd228deec786e739a",
      "/app/views/decidim/devise/registrations/new.html.erb" => "5f6f15330839fa55697c4e272767a090"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    # rubocop:disable Rails/DynamicFindBy
    spec = ::Gem::Specification.find_by_name(item[:package])
    # rubocop:enable Rails/DynamicFindBy
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
