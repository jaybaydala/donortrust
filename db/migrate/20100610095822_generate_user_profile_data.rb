class GenerateUserProfileData < ActiveRecord::Migration
  def self.up    
    say "Trying to assign users a default short name and copy their bio (this may take a while). Processing #{User.all.size} user profiles..."
    short_names_used = []
    User.find(:all, :conditions => ["activation_code IS NULL AND deleted_at IS NULL"]).each do |user|
      user.profile
      # Set the short name
      case true
      when ((user.display_name =~ /^[a-zA-Z0-9_]+$/) and (!short_names_used.include?(user.display_name.downcase)))
        short_names_used << user.profile.update_attribute(:short_name, user.display_name.downcase)
      when (user.participants.collect(&:short_name).compact.uniq.size == 1)
        short_names_used << user.profile.update_attribute(:short_name, user.participants.first.short_name)
      when ((user.first_name && user.last_name) and ("#{user.first_name.downcase}_#{user.last_name.downcase}" =~ /^[a-z_]+$/) and (!short_names_used.include?("#{user.first_name.downcase}_#{user.last_name.downcase}")))
        short_names_used << user.profile.update_attribute(:short_name, "#{user.first_name.downcase}_#{user.last_name.downcase}")
      end
      # Set the description
      user.profile.update_attribute(:description, user.bio) unless user.bio.blank?
    end
    
  end

  def self.down
    
  end
end
