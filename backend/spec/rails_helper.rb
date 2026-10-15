ENV["RAILS_ENV"] ||= "test"
ENV["JWT_SECRET"] ||= "test-only-secret"
require_relative "../config/environment"
require "rspec/rails"

ActiveRecord::Migration.maintain_test_schema!

module AuthHelpers
  def auth_headers(user)
    { "Authorization" => "Bearer #{JsonWebToken.encode(sub: user.id)}" }
  end

  def create_member(org, role:, email: "#{role}-#{SecureRandom.hex(3)}@example.test")
    user = User.create!(name: role.to_s.capitalize, email: email, password: "password123")
    Membership.create!(user: user, organization: org, role: role)
    user
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.include AuthHelpers, type: :request
end
