class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password].to_s)
      if user.otp_enabled?
        render json: { mfa_required: true, user_id: user.id }
      else
        render json: session_payload(user)
      end
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def verify_mfa
    user = User.find(params[:user_id])

    if user.verify_otp(params[:code])
      render json: session_payload(user)
    else
      Rails.logger.warn("MFA verification failed for #{user.email} with code #{params[:code]}")
      render json: { error: "Invalid code" }, status: :unauthorized
    end
  end

  private

  def session_payload(user)
    { token: JsonWebToken.encode(sub: user.id), user: UserSerializer.new(user).as_json }
  end
end
