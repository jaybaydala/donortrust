class PartnerStatus < ActiveRecord::Base
  has_many :partners#, :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  validates_length_of :name, :maximum => 25
  validates_length_of :description, :maximum => 250

  def destroy
    result = false
    if partners.count > 0
#      errors.add_to_base( "Can not destroy a #{self.class.to_s} that has Partners" )
      raise( "Can not destroy a #{self.class.to_s} that has Partners" )
    else
      result = super
    end
    return result
  end

  def partners_count
    return partners.count
  end
end
