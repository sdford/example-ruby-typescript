class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :created_by, class_name: "User"
  has_many :measurements, dependent: :destroy

  enum :status, { scanning: 0, processing: 1, ready: 2 }

  validates :name, :address, presence: true
end
