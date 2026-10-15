class User < ApplicationRecord
  has_secure_password

  has_one :membership, dependent: :destroy
  has_one :organization, through: :membership

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
end
