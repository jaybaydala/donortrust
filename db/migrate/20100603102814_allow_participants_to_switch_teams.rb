class AllowParticipantsToSwitchTeams < ActiveRecord::Migration
  def self.up
    add_column :participants, :active, :boolean
    
    say "Making all current participants active"
    Participant.all.each do |p|
      p.active = true
      p.save
    end
  end

  def self.down
    # Return all investments to the participant's current team
    # (not technically consistent when rolling back, but best effort)
    say "Re-assigning all pledges to participants\' current teams"
    Participant.all.group_by(&:user_id).each do |user_id, participants|
      if User.exists?(user_id)
        user = User.find(user_id)
        participants.group_by(&:campaign).each do |campaign, participants|
          if participants.find{|p| p.active}
            active_id = participants.find{|p| p.active}.id
            participants.each do |p|
              p.pledges.each do |pledge|
                pledge.participant_id = active_id
                pledge.save
              end
              p.destroy unless p.id == active_id
            end
          end
        end
      end
    end
    
    remove_column :participants, :active
  end
end
