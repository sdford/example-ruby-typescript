class MfaController < ApplicationController
  before_action -> { require_role!(:admin) }, only: [:status, :reset]

  def setup
    current_user.update!(otp_secret: ROTP::Base32.random)

    render json: {
      secret: current_user.otp_secret,
      provisioning_uri: current_user.totp.provisioning_uri(current_user.email)
    }
  end

  def enable
    if current_user.verify_otp(params[:code])
      current_user.update!(otp_enabled: true)
      render json: { backup_codes: current_user.generate_backup_codes! }
    else
      render json: { error: "Invalid code" }, status: :unprocessable_entity
    end
  end

  def backup_codes
    render json: { backup_codes: current_user.otp_backup_codes }
  end

  def destroy
    current_user.reset_mfa!
    head :no_content
  end

  # Admin view of which teammates have MFA turned on.
  def status
    rows = current_org.memberships.order(:created_at).map do |m|
      { user_id: m.user_id, name: m.user.name, email: m.user.email, role: m.role, mfa_enabled: m.user.otp_enabled? }
    end
    render json: rows
  end

  # For teammates who lost their phone.
  def reset
    User.find(params[:user_id]).reset_mfa!
    head :no_content
  end
end
