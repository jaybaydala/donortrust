class GroupNews < ActiveRecord::Base
  validates_presence_of :message, :user_id, :group_id
  belongs_to :group
  belongs_to :user
end
