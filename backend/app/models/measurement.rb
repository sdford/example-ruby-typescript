class Measurement < ApplicationRecord
  belongs_to :project

  KINDS = %w[roof_area siding_area window_count gutter_length].freeze

  validates :kind, inclusion: { in: KINDS }
  validates :value, numericality: { greater_than_or_equal_to: 0 }
end
