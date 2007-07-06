class ProjectStatus < ActiveRecord::Base
  has_many :projects 
  has_many :project_histories

  validates_presence_of :name
  validates_uniqueness_of :name

#  def to_label
#    "#{status_type}"
#  end

  def destroy
    result = false
    if projects.count > 0
      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Projects" )
    else
      result = super
    end
    return result
  end

  def projects_count
    return projects.count
  end
end