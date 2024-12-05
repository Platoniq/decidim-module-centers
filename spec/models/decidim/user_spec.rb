# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe User do
    subject { user }

    let(:user) { create :user }

    describe "centers" do
      context "without center" do
        it "has no center_users" do
          expect(subject.center_users).to eq []
        end

        it "has no centers" do
          expect(subject.centers).to eq []
        end

        it "has no center" do
          expect(subject.center).to be_nil
        end
      end

      context "with center" do
        let!(:center_user) { create :center_user, user: user }

        it "has center_users" do
          expect(subject.center_users).to eq Centers::CenterUser.all
        end

        it "has centers" do
          expect(subject.centers).to eq Centers::Center.all
        end

        it "has center" do
          expect(subject.center).to eq Centers::Center.first
        end
      end
    end

    describe "roles" do
      context "without role" do
        it "has no role_users" do
          expect(subject.role_users).to eq []
        end

        it "has no roles" do
          expect(subject.roles).to eq []
        end

        it "has no rule" do
          expect(subject.rule).to be_nil
        end
      end

      context "with role" do
        let!(:role_user) { create :role_user, user: user }

        it "has role_users" do
          expect(subject.role_users).to eq Centers::RoleUser.all
        end

        it "has roles" do
          expect(subject.roles).to eq Centers::Role.all
        end

        it "has role" do
          expect(subject.role).to eq Centers::Role.first
        end
      end
    end

    describe "scopes" do
      context "without scope" do
        it "has no scope_users" do
          expect(subject.scope_users).to eq []
        end

        it "has no scopes" do
          expect(subject.scopes).to eq []
        end

        it "has no scope" do
          expect(subject.scope).to be_nil
        end
      end

      context "with scope" do
        let!(:scope_user) { create :scope_user, user: user }

        it "has scope_users" do
          expect(subject.scope_users).to eq Centers::ScopeUser.all
        end

        it "has scopes" do
          expect(subject.scopes).to eq Scope.all
        end

        it "has scope" do
          expect(subject.scope).to eq Scope.first
        end
      end
    end
  end
end
