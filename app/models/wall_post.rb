class WallPost < ActiveRecord::Base
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  belongs_to :postable, :polymorphic => true

  validates_length_of :wall_text, :within => 1...250, :message => "Wall messages cannot be blank, and must be less than 250 characters"

  def owned?
    self.author == current_user
  end

end
