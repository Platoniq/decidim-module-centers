# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This controller allows the create or update a center.
      class CentersController < ApplicationController
        helper_method :centers, :center

        def new
          enforce_permission_to :create, :center
          @form = form(CenterForm).instance
        end

        def create
          enforce_permission_to :create, :center
          @form = form(CenterForm).from_params(params)

          CreateCenter.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("centers.create.success", scope: "decidim.centers.admin")
              redirect_to centers_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("centers.create.invalid", scope: "decidim.centers.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :center, center: center
          @form = form(CenterForm).from_model(center)
        end

        def update
          enforce_permission_to :update, :center, center: center
          @form = form(CenterForm).from_params(params)

          UpdateCenter.call(@form, center, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("centers.update.success", scope: "decidim.centers.admin")
              redirect_to centers_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("centers.update.invalid", scope: "decidim.centers.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :center, center: center

          DestroyCenter.call(center, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("centers.destroy.success", scope: "decidim.centers.admin")
            end
          end

          redirect_to centers_path
        end

        private

        def center
          @center ||= filtered_centers.find(params[:id])
        end

        def centers
          @centers ||= filtered_centers.page(params[:page]).per(15)
        end

        def filtered_centers
          Center.where(organization: current_organization).not_deleted
        end
      end
    end
  end
end
