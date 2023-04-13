# frozen_string_literal: true

# industry sector
# an employer can be in multiple sectors
class Sector < ApplicationRecord
  default_scope { order(:name) }

  has_many :employer_sectors, dependent: :destroy
  has_many :employers, through: :employer_sectors

  def self.selection_list
    order(:name).pluck(:name, :id)
  end
end
