class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password].to_s)
      render json: { token: JsonWebToken.encode(sub: user.id), user: UserSerializer.new(user).as_json }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end
end
