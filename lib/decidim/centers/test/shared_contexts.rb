# frozen_string_literal: true

def check_center_authorization(authorization, user, center)
  expect(authorization.name).to eq("center")
  expect(authorization.user).to eq(user)
  expect(authorization.metadata["centers"]).to include(center.id)
end

shared_examples_for "no authorization is created" do
  it "does not create an authorization" do
    expect { subject.perform_now(params) }.not_to change(Decidim::Authorization, :count)
  end
end
