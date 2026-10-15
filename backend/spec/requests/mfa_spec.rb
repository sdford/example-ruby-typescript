require "rails_helper"

RSpec.describe "MFA", type: :request do
  let(:org) { Organization.create!(name: "Ridgeline") }
  let(:admin) { create_member(org, role: :admin, email: "admin@example.test") }
  let(:editor) { create_member(org, role: :editor, email: "editor@example.test") }

  describe "enrollment" do
    it "returns a secret and provisioning uri" do
      post "/mfa/setup", headers: auth_headers(editor)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["provisioning_uri"]).to start_with("otpauth://totp/")
    end

    it "enables mfa with a valid code and returns backup codes" do
      post "/mfa/setup", headers: auth_headers(editor)

      post "/mfa/enable", params: { code: "123456" }, headers: auth_headers(editor)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["backup_codes"].size).to eq(10)
      expect(editor.reload.otp_enabled).to be(true)
    end
  end

  describe "login" do
    before do
      editor.update!(otp_secret: ROTP::Base32.random, otp_enabled: true)
    end

    it "asks for a code after the password" do
      post "/login", params: { email: editor.email, password: "password123" }

      expect(response.parsed_body).to include("mfa_required" => true)
      expect(response.parsed_body).not_to have_key("token")
    end

    it "issues a token after a valid code" do
      post "/login/mfa", params: { user_id: editor.id, code: "123456" }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["token"]).to be_present
    end
  end

  describe "admin tools" do
    it "lists mfa status for the org" do
      editor

      get "/mfa/status", headers: auth_headers(admin)

      expect(response.parsed_body.map { |r| r["email"] }).to include("editor@example.test")
    end

    it "resets a teammate" do
      editor.update!(otp_secret: ROTP::Base32.random, otp_enabled: true)

      post "/users/#{editor.id}/mfa/reset", headers: auth_headers(admin)

      expect(response).to have_http_status(:no_content)
      expect(editor.reload.otp_enabled).to be(false)
    end
  end
end
