class ProjectStatus < ActiveRecord::Base
  acts_as_paranoid
  has_many :projects

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description

#  def destroy
#    result = false
#    if projects.count > 0
##      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Projects" )
#      raise( "Can not destroy a #{self.class.to_s} that has Projects" )
#    else
#      result = super
#    end
#    return result
#  end

  def project_count
    return projects.count
  end
end