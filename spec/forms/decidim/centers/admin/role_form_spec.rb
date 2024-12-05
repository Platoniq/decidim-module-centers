# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    module Admin
      describe RoleForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization
          )
        end

        let(:current_organization) { create :organization }

        let(:title) do
          {
            "en" => "Title",
            "ca" => "Títol",
            "es" => "Título"
          }
        end

        let(:attributes) do
          {
            "role" => {
              "title" => title
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when title is missing" do
          let(:title) do
            { "en" => "" }
          end

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
