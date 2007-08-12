class PartnerType < ActiveRecord::Base
  has_many :partners

  validates_length_of :name, :maximum => 50
  validates_presence_of :name, :description
  
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

  def partner_count
    return partners.count
  end
end
