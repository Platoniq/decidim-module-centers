# frozen_string_literal: true

def check_center_authorization(authorization, user, center, scope: nil, role: nil)
  expect(authorization.name).to eq("center")
  expect(authorization.user).to eq(user)
  expect(authorization.metadata["centers"]).to include(center.id)
  expect(authorization.metadata["scopes"]).to include(scope.id) if scope
  expect(authorization.metadata["roles"]).to include(role.id) if role
end

shared_examples_for "no authorization is created" do
  it "does not create an authorization" do
    expect { subject.perform_now(params) }.not_to change(Decidim::Authorization, :count)
  end
end

shared_context "with scopes disabled" do
  let(:scope) { nil }

  before do
    allow(Decidim::Centers).to receive(:scopes_enabled).and_return(false)
  end
end

shared_context "with roles disabled" do
  let(:role) { nil }

  before do
    allow(Decidim::Centers).to receive(:roles_enabled).and_return(false)
  end
end
