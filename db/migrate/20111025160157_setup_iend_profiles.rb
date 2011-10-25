class SetupIendProfiles < ActiveRecord::Migration
  def self.up
    # this should set up all the iend profiles automatically
    User.all.each(&:touch)
  end

  def self.down
  end
end
