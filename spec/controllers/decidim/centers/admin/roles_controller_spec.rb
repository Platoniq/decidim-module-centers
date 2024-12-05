# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Centers
    module Admin
      describe RolesController, type: :controller do
        routes { Decidim::Centers::AdminEngine.routes }

        let(:organization) { create :organization }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let!(:roles) { create_list :role, 20, organization: organization }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user, scope: :user
        end

        describe "#index" do
          it "renders the index template" do
            get :index

            expect(response).to render_template(:index)
          end
        end

        describe "#new" do
          it "renders the new template" do
            get :new

            expect(response).to render_template(:new)
          end
        end

        describe "#edit" do
          let(:params) do
            {
              id: id
            }
          end

          context "with valid params" do
            let(:id) { roles.first.id }

            it "renders the edit template" do
              get :edit, params: params

              expect(response).to render_template(:edit)
            end
          end

          context "with non existing record" do
            let(:id) { -1 }

            it "raise not found exception" do
              expect { get :edit, params: params }.to raise_error(ActiveRecord::RecordNotFound)
            end
          end
        end

        describe "#create" do
          let(:params) do
            {
              title: {
                en: title
              }
            }
          end

          context "with invalid params" do
            let(:title) { "" }

            it "renders the new template" do
              post :create, params: params

              expect(response).to render_template(:new)
            end
          end

          context "with valid params" do
            let(:title) { "My title" }

            it "redirects to index" do
              expect(controller).to receive(:redirect_to) do |params|
                expect(params).to eq("/roles")
              end

              post :create, params: params
            end
          end
        end

        describe "#update" do
          let(:params) do
            {
              id: id,
              title: {
                en: title
              }
            }
          end

          context "with existing record" do
            let(:id) { roles.first.id }

            context "with invalid params" do
              let(:title) { "" }

              it "renders the edit template" do
                put :update, params: params

                expect(response).to render_template(:edit)
              end
            end

            context "with valid params" do
              let(:title) { "My title" }

              it "redirects to index" do
                expect(controller).to receive(:redirect_to) do |params|
                  expect(params).to eq("/roles")
                end

                put :update, params: params
              end
            end
          end

          context "with non existing record" do
            let(:id) { -1 }
            let(:title) { "My title" }

            it "raise not found exception" do
              expect { put :update, params: params }.to raise_error(ActiveRecord::RecordNotFound)
            end
          end
        end

        describe "#destroy" do
          let(:params) do
            {
              id: id
            }
          end

          context "with existing record" do
            let(:id) { roles.first.id }

            it "redirects to index" do
              expect(controller).to receive(:redirect_to) do |params|
                expect(params).to eq("/roles")
              end

              delete :destroy, params: params
            end
          end

          context "with non existing record" do
            let(:id) { -1 }

            it "raise not found exception" do
              expect { delete :destroy, params: params }.to raise_error(ActiveRecord::RecordNotFound)
            end
          end
        end
      end
    end
  end
end
