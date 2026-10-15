class ShareLinksController < ApplicationController
  def index
    links = ShareLink.where(project_id: current_org.projects.select(:id)).order(created_at: :desc)

    render json: links.map { |link|
      {
        id: link.id,
        url: share_url(link),
        project_name: link.project.name,
        created_by: link.created_by.name,
        views: link.share_link_views.count,
        expires_at: link.expires_at
      }
    }
  end

  def create
    project = Project.find(params[:project_id])
    link = project.share_links.create!(created_by: current_user, expires_at: params[:expires_at])

    Rails.logger.info("Share link created for project #{project.id} by #{current_user.email}: #{link.token}")
    render json: { id: link.id, url: share_url(link), qr_svg: RQRCode::QRCode.new(share_url(link)).as_svg(module_size: 4) },
           status: :created
  end

  def destroy
    ShareLink.find(params[:id]).destroy
    head :no_content
  end

  private

  def share_url(link)
    "#{ENV.fetch('APP_URL', 'http://localhost:5173')}/s/#{link.token}"
  end
end
