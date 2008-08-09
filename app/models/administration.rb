class Administration < ActiveRecord::Base
  before_save :add_role
  belongs_to :administrable, :polymorphic =>true
  belongs_to :user
  belongs_to :role

  def add_role
    unless self.role
      role = Role.find_or_create_by_title(self.administrable_type.downcase+"_admin")
      self.role = role
    end
  end
end
