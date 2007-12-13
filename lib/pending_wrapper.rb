class PendingWrapper
  
  attr_accessor :real_object, :pending_object
  
  def initialize(pending_obj, real_obj)
    self.pending_object = pending_obj
    self.real_object = real_obj
  end
  
end