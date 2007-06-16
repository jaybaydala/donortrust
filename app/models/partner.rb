class Partner < ActiveRecord::Base
  acts_as_versioned

#  after_save  :create_partner_history
#  after_save :save_partner_history
  
  belongs_to    :partner_type
  belongs_to    :partner_status
  has_many      :partner_versions
  has_and_belongs_to_many :contacts #is this the right relationship? 
  
  validates_presence_of :name, :partner_type_id, :partner_status_id
  validates_length_of   :name, :maximum => 50
  validates_length_of   :description, :maximum => 1000
  
  def create_partner_history
    if Partner.exists?(self.id)
      @create_partner_history_ph = PartnerHistory.new_audit(Partner.find(self.id))
    end
  end
  
  def save_partner_history
    if (@create_partner_history_ph)
      @create_partner_history_ph.save
      @create_partner_history_ph = nil
    end
  end
  
  #  def save_with_audit
  #    save_result       = false
  #    
  #    if (self.save)
  #      ph                    = PartnerHistory.new_audit(self)
  #      save_result           = ph.save
  #    end
  #    return save_result
  #  end
  
  def self.is_a_partner?(object)
    return object.class.to_s == "Partner"
  end
end
