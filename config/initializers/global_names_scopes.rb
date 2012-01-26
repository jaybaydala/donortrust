# http://railscasts.com/episodes/112-anonymous-scopes
class ActiveRecord::Base
  named_scope :conditions, lambda { |*args| {:conditions => args} }
end
