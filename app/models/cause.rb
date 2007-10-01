class Cause < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :sector 
  has_many :projects

  validates_presence_of     :name
  validates_uniqueness_of   :name, :scope => :sector_id
  validates_presence_of     :description

  validate do |cause|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless cause.sector( true )
      cause.errors.add :sector_id, 'does not exist'
    end
  end

  def project_count
    return projects.count
  end
end
