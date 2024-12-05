# frozen_string_literal: true

module Decidim
  module Centers
    module Admin
      # This controller allows the create or update a role.
      class RolesController < ApplicationController
        include TranslatableAttributes

        helper_method :roles, :role

        def index
          enforce_permission_to :index, :role
          respond_to do |format|
            format.html
            format.json do
              render json: json_roles
            end
          end
        end

        def new
          enforce_permission_to :create, :role
          @form = form(RoleForm).instance
        end

        def create
          enforce_permission_to :create, :role
          @form = form(RoleForm).from_params(params)

          CreateRole.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("roles.create.success", scope: "decidim.centers.admin")
              redirect_to roles_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("roles.create.invalid", scope: "decidim.centers.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :role, role: role
          @form = form(RoleForm).from_model(role)
        end

        def update
          enforce_permission_to :update, :role, role: role
          @form = form(RoleForm).from_params(params)

          UpdateRole.call(@form, role, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("roles.update.success", scope: "decidim.centers.admin")
              redirect_to roles_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("roles.update.invalid", scope: "decidim.centers.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :role, role: role

          DestroyRole.call(role, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("roles.destroy.success", scope: "decidim.centers.admin")
            end
          end

          redirect_to roles_path
        end

        private

        def json_roles
          query = filtered_roles
          query = query.where(id: params[:ids]) if params[:ids]
          query = query.where("title->>? ilike ?", I18n.locale, "%#{params[:q]}%") if params[:q]
          query.map do |item|
            {
              id: item.id,
              text: translated_attribute(item.title)
            }
          end
        end

        def role
          @role ||= filtered_roles.find(params[:id])
        end

        def roles
          @roles ||= filtered_roles.page(params[:page]).per(15)
        end

        def filtered_roles
          Role.where(organization: current_organization).not_deleted
        end
      end
    end
  end
end
