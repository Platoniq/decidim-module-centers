# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      class ScopesController < ApplicationController
        include TranslatableAttributes

        helper_method :scopes

        def index
          enforce_permission_to :read, :scope
          respond_to do |format|
            format.json do
              render json: json_scopes
            end
          end
        end

        private

        def json_scopes
          query = scopes
          query = query.where(id: params[:ids]) if params[:ids]
          query = query.where("name->>? ilike ?", I18n.locale, "%#{params[:q]}%") if params[:q]
          query.map do |item|
            {
              id: item.id,
              text: translated_attribute(item.name)
            }
          end
        end

        def scopes
          @scopes ||= Scope.where(organization: current_organization)
        end
      end
    end
  end
end
