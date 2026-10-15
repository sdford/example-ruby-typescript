class MembershipsController < ApplicationController
  def index
    memberships = current_org.memberships.includes(:user)
    render json: memberships.map { |m| { id: m.id, role: m.role, user: UserSerializer.new(m.user).as_json } }
  end

  def update
    membership = current_org.memberships.find(params[:id])
    membership.update!(membership_params)
    render json: { id: membership.id, role: membership.role }
  end

  private

  def membership_params
    params.require(:membership).permit(:role, :organization_id)
  end
end
