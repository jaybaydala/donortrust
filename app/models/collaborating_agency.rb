class CollaboratingAgency < ActiveRecord::Base
  has_many :projects, :through => :collaborations
  has_many :collaborations

  # Make active scaffold use this column to represent the "name" of this collaborating agency
  def to_label
    "#{agency_name}"
  end
end
