class DefaultDtRecords < ActiveRecord::Migration
  def self.up
    # this is just in place to ensure that we have our defaults set up across the system. 
    # to this point, we've been depending on manually created data. 
    # while this doesn't guarantee that it stays there, it's something to start with (and test against)
    
    # PlaceType 
    %w( Continent Country State District Region City ).each do |place_type|
      PlaceType.create!(:name => place_type) unless PlaceType.find(:first, :conditions => ["name LIKE ?", place_type])
    end
    # ProjectStatus
    ["Slated", "Started", "Canceled", "Completed", "In Marketing"].each do |project_status| 
      ProjectStatus.create!(:name => project_status) unless ProjectStatus.find(:first, :conditions => ["name LIKE ?", project_status])
    end
  end

  def self.down
  end
end
