# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :center, class: "Decidim::Centers::Center" do
    organization { create :organization }
    title { generate_localized_title }
    deleted_at { nil }

    trait :deleted do
      deleted_at { Time.current }
    end
  end

  factory :center_user, class: "Decidim::Centers::CenterUser" do
    user { create :user }
    center { create :center, organization: user.organization }
  end

  factory :scope_user, class: "Decidim::Centers::ScopeUser" do
    user { create :user }
    scope { create :scope, organization: user.organization }
  end
end
