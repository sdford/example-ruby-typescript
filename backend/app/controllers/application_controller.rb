class ApplicationController < ActionController::API
  class NotAuthorized < StandardError; end

  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from NotAuthorized, with: :forbidden

  private

  attr_reader :current_user

  def authenticate_user!
    token = request.headers["Authorization"].to_s.delete_prefix("Bearer ")
    payload = JsonWebToken.decode(token)
    @current_user = payload && User.find_by(id: payload["sub"])
    head :unauthorized unless @current_user
  end

  def current_membership
    @current_membership ||= current_user.membership
  end

  def current_org
    current_membership.organization
  end

  # Usage: require_role!(:editor, :admin)
  def require_role!(*roles)
    raise NotAuthorized unless roles.map(&:to_s).include?(current_membership.role)
  end

  def not_found
    head :not_found
  end

  def forbidden
    head :forbidden
  end
end
