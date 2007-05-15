class Partner < ActiveRecord::Base
  belongs_to              :partner_type
  belongs_to              :partner_status
  has_many                :partner_histories
#  has_and_belongs_to_many :contacts
  
  validates_presence_of :name, :partner_type_id, :partner_status_id
  validates_length_of   :name, :maximum => 50
  validates_length_of   :description, :maximum => 1000
  
#  def save_with_audit
#    save_result       = false
#    
#    if (self.save)
#      ph                    = PartnerHistory.new_audit(self)
#      save_result           = ph.save
#    end
#    return save_result
#  end
  
#  def self.is_a_partner?(object)
#    return object.class.to_s == "Partner"
#  end
end
