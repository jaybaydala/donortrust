class PartnerHistory < ActiveRecord::Base
  belongs_to  :partner
  belongs_to :partner_type
  belongs_to :partner_status
  
  def self.new_audit (partner)
    raise ArgumentError, "Need a Partner, not a '#{partner.class.to_s}'" if not partner.class.to_s == 'Partner' #Partner.is_a_partner?(partner)
    
    ph                    = PartnerHistory.new
    ph.partner_id         = partner.id
    ph.name               = partner.name
    ph.description        = partner.description
    ph.partner_type_id    = partner.partner_type_id
    ph.partner_status_id  = partner.partner_status_id
    
    return ph
  end
  
  def save_audit ( partner )
    raise ArgumentError, "Need a Partner, not a '#{partner.class.to_s}'" if not Partner.is_a_partner?(partner)
    #raise ArgumentError, "Partner to history id mismatch" if not partner.id == self.partner_id
    raise RangeError, "no change to partner" if self.matches(partner)
    save_result               = false
    partner.name              = self.name
    partner.description       = self.description
    partner.partner_type_id   = self.partner_type_id
    partner.partner_status_id = self.partner_status_id
    self.partner_id           = partner.id
    
    return save_result    
  end
  
  def matches (partner)
    matches = true
    matches = matches && partner.id                 != self.partner_id
    matches = matches && partner.name               != self.name
    matches = matches && partner.description        != self.description
    matches = matches && partner.partner_type_id    != self.partner_type_id
    matches = matches && partner.partner_status_id  != self.partner_status_id
    return matches
  end
end
