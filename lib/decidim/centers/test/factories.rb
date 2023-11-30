# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  # Add engine factories here
  factory :center, class: "Decidim::Centers::Center" do
    organization { create :organization }
    title { generate_localized_title }
    deleted_at { nil }

    trait :deleted do
      deleted_at { Time.current }
    end
  end
end
