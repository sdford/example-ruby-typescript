class ProjectsController < ApplicationController
  before_action -> { require_role!(:editor, :admin) }, only: [:create, :update]

  PAGE_SIZE = 500

  def index
    projects = current_org.projects.order(updated_at: :desc).limit(PAGE_SIZE).offset(page_offset)
    render json: projects.map { |p| ProjectSerializer.new(p).as_json }
  end

  def show
    project = current_org.projects.includes(:measurements).find(params[:id])
    render json: ProjectSerializer.new(project, include_measurements: true).as_json
  end

  def create
    project = current_org.projects.new(project_params.merge(created_by: current_user))

    if project.save
      render json: ProjectSerializer.new(project).as_json, status: :created
    else
      render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    project = current_org.projects.find(params[:id])

    if project.update(project_params)
      render json: ProjectSerializer.new(project).as_json
    else
      render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :address, :notes)
  end

  def page_offset
    [params[:page].to_i - 1, 0].max * PAGE_SIZE
  end
end
