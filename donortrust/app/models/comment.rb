class Comment < ActiveRecord::Base
  
  validates_presence_of :name, :email, :comment , :on => :create
  
end
