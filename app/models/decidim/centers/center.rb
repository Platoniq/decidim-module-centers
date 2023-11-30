# frozen_string_literal: true

module Decidim
  module Centers
    class Center < Centers::ApplicationRecord
      include Decidim::TranslatableResource

      translatable_fields :title

      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      scope :not_deleted, -> { where(deleted_at: nil) }

      def deleted?
        deleted_at.present?
      end

      def self.log_presenter_class_for(_log)
        Decidim::Centers::AdminLog::CenterPresenter
      end
    end
  end
end
