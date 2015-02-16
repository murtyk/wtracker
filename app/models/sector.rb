# industry sector
# an employer can be in multiple sectors
class Sector < ActiveRecord::Base
  default_scope { order(:name) }
  attr_accessible :name
  alias_attribute(:sector_name, :name)

  has_many :employer_sectors, dependent: :destroy
  has_many :employers, through: :employer_sectors

  def self.selection_list
    order(:name).pluck(:name, :id)
  end
end
