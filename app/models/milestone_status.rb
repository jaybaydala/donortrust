class MilestoneStatus < ActiveRecord::Base
  has_many :milestones

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description

  def destroy
    result = false
    if milestones.count > 0
      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Milestones" )
    else
      result = super
    end
    return result
  end

  def milestones_count
    return milestones.count
  end
end
