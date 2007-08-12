class GroupType < ActiveRecord::Base
  has_many :groups

  validates_presence_of     :name
  validates_uniqueness_of   :name

  def destroy
    result = false
    if groups.count > 0
#      errorsadd_to_base( "Can not destroy a #{self.class.to_s} that has Groups" )
      raise( "Can not destroy a #{self.class.to_s} that has Groups" )
    else
      result = super
    end
    return result
  end

  def group_count
    return groups.count
  end
end
