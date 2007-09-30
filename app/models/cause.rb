class Cause < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :sector 
  has_many :projects

  validates_presence_of     :name
  validates_uniqueness_of   :name
  validates_presence_of     :description
  validates_presence_of     :sector

  def project_count
    return projects.count
  end
end
