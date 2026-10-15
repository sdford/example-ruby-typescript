# Public, unauthenticated view of a project for homeowners who receive a share link.
class SharedProjectsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    link = ShareLink.find_by!(token: params[:token])
    ShareLinkView.create!(share_link: link, ip_address: request.remote_ip, user_agent: request.user_agent)
    link.update!(view_count: link.view_count + 1)

    render json: link.project.as_json(include: [:measurements, :created_by, :organization])
  rescue => e
    render json: { error: e.message, backtrace: e.backtrace.first(5) }, status: :internal_server_error
  end
end
