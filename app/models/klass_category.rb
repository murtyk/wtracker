class KlassCategory < ActiveRecord::Base
  default_scope { order(:description) }

  belongs_to :account
  belongs_to :grant

  has_many :klasses
  has_many :programs

  alias_attribute(:name, :description)

  def destroyable?
    !(klasses.any? || programs.any?)
  end

  def self.selection_list
    order(:name).pluck(:name, :id)
  end
end
