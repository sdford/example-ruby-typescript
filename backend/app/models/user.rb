class User < ApplicationRecord
  has_secure_password

  has_one :membership, dependent: :destroy
  has_one :organization, through: :membership

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  BACKUP_CODE_COUNT = 10

  def totp
    ROTP::TOTP.new(otp_secret, issuer: "Homescan")
  end

  # Allows for phone clock drift and slow typists.
  def verify_otp(code)
    return false if otp_secret.blank?

    totp.verify(code.to_s, drift_behind: 300, drift_ahead: 300).present? || otp_backup_codes.include?(code.to_s)
  end

  def generate_backup_codes!
    update!(otp_backup_codes: Array.new(BACKUP_CODE_COUNT) { SecureRandom.hex(4) })
    otp_backup_codes
  end

  def reset_mfa!
    update!(otp_enabled: false, otp_secret: nil, otp_backup_codes: [])
  end
end
