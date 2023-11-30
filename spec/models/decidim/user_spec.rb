# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe User do
    subject { user }

    let(:user) { create :user }

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

      it "has no centers" do
        expect(subject.centers).to eq Centers::Center.all
      end

      it "has no center" do
        expect(subject.center).to eq Centers::Center.first
      end
    end
  end
end
