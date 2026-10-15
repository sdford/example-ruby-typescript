class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      role: @user.membership&.role,
      mfa_enabled: @user.otp_enabled?
    }
  end
end
