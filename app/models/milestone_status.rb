class MilestoneStatus < ActiveRecord::Base
  acts_as_paranoid
#  before_create :check_deleted
#  before_update :check_deleted

  has_many :milestones

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description

  def milestones_count
    return milestones.count
  end

# Acts_as_paranoid does not have 'quite' the functionality desired.  If an instance is deleted,
# AAP sets a deletion date instead of actually deleting the instances, *BUT* creating a new
# instance with the same name (as the deleted instance) *works*.  This bypasses the
# validates_uniqueness_of :name check.  *really* want the create attempt to fail.  Should restore
# the previously [marked as] deleted instance instead.

  def validate_on_create
    check_deleted
  end
  
  def validate_on_update
    check_deleted
  end
  
  protected
  def check_deleted
    check_result = true
    existing = MilestoneStatus.find_with_deleted( :all, :conditions => [ "name = ?", name ])
    if existing.size > 0 then
      # if existing.size > 1 then exception duplicates already exists
      if not existing[ 0 ].deleted_at.nil? then
        check_result = false 
        self.errors.add :name, 'already exists but is inactive'
      end
    end
    return check_result
  end
end
