require "rails_helper"

RSpec.describe "Share links", type: :request do
  let(:org) { Organization.create!(name: "Ridgeline") }
  let(:editor) { create_member(org, role: :editor) }
  let!(:project) { org.projects.create!(name: "Kim", address: "412 Alder St", created_by: editor) }

  it "creates a share link" do
    post "/projects/#{project.id}/share_links", headers: auth_headers(editor)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body["url"]).to include("/s/")
  end

  it "shows a shared project without auth" do
    link = project.share_links.create!(created_by: editor)

    get "/shared/#{link.token}"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["name"]).to eq("Kim")
  end
end
