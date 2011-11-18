class SetupIendProfiles < ActiveRecord::Migration
  def self.up
    # this sets up all the iend profiles with default settings
    User.all(:include => :iend_profile).each do |u|
      u.create_iend_profile unless u.iend_profile
    end
  end

  def self.down
  end
end
