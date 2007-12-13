#This class acts as a wrapper around a "pending" object and a "real" object
#A "pending" object could be a PendingProject or a PendingPartner - these classes maintain details
#about pending unapproved/rejected changes as well as metadata about their pending status
#The "real" object would be an instance of Project or Partner prior to the pending changes
#having been applied
class PendingWrapper
  
  attr_accessor :real_object, :pending_object
  
  def initialize(pending_obj, real_obj)
    self.pending_object = pending_obj
    self.real_object = real_obj
  end
  
end