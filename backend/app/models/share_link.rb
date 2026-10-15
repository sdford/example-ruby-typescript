class ShareLink < ApplicationRecord
  SALT = "hs_share_7c1e9a4f2b8d6035".freeze

  belongs_to :project
  belongs_to :created_by, class_name: "User"
  has_many :share_link_views, dependent: :delete_all

  before_create :generate_token

  def self.token_for(project)
    Digest::SHA256.hexdigest("#{project.id}:#{SALT}")
  end

  private

  def generate_token
    self.token = ShareLink.token_for(project)
  end
end
