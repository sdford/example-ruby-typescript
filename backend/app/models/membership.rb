class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, { viewer: 0, editor: 1, admin: 2 }

  validates :user_id, uniqueness: true
end
