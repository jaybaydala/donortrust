class OldTeamMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :old_team
end
