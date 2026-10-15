module JsonWebToken
  ALGORITHM = "HS256".freeze
  TTL = 1.hour

  def self.encode(payload)
    JWT.encode(payload.merge(exp: TTL.from_now.to_i), secret, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, secret, true, algorithm: ALGORITHM).first
  rescue JWT::DecodeError
    nil
  end

  def self.secret
    ENV["JWT_SECRET"].presence || Rails.application.credentials.jwt_secret || raise("JWT secret is not configured")
  end
end
