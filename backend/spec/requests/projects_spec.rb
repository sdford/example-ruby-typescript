require "rails_helper"

RSpec.describe "Projects", type: :request do
  let(:org) { Organization.create!(name: "Ridgeline") }
  let(:other_org) { Organization.create!(name: "Competitor") }
  let(:editor) { create_member(org, role: :editor) }
  let(:viewer) { create_member(org, role: :viewer) }
  let!(:project) { org.projects.create!(name: "Kim", address: "412 Alder St", created_by: editor) }

  describe "GET /projects/:id" do
    it "returns the project with measurements" do
      project.measurements.create!(kind: "roof_area", value: 2310, unit: "sqft")

      get "/projects/#{project.id}", headers: auth_headers(viewer)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["measurements"].first["kind"]).to eq("roof_area")
    end

    it "does not leak projects from another organization" do
      outsider = create_member(other_org, role: :admin)

      get "/projects/#{project.id}", headers: auth_headers(outsider)

      expect(response).to have_http_status(:not_found)
    end

    it "rejects requests without a token" do
      get "/projects/#{project.id}"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /projects/:id" do
    it "lets editors update" do
      patch "/projects/#{project.id}", params: { project: { name: "Kim reroof" } }, headers: auth_headers(editor)

      expect(response).to have_http_status(:ok)
      expect(project.reload.name).to eq("Kim reroof")
    end

    it "forbids viewers" do
      patch "/projects/#{project.id}", params: { project: { name: "nope" } }, headers: auth_headers(viewer)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
