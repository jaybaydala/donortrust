class AddContinentAndCountryShortcutsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :continent_id, :integer
    add_column :projects, :country_id, :integer

    add_column :project_versions, :short_description, :string, :limit => 255
    add_column :project_versions, :continent_id, :integer
    add_column :project_versions, :country_id, :integer
    
    add_column :places, :country_id, :integer

    say_with_time "Adding country ID shortcuts to places. This might take several minutes. Please be patient..." do
      counter = 0
      all = Place.find(:all,
                       :conditions => "place_type_id != 1 AND place_type_ID != 2 AND parent_id is not NULL AND country_id is NULL")
      all.each do |p|
        # find country
        temp = p.parent
        while temp.place_type.id != 2 and temp.parent and not temp.country_id
          temp = temp.parent
        end
        
        # save shortcut to country
        if temp.parent
          p.country_id = temp.country_id || temp.id
          p.save!
        end
        
        puts "#{counter}/#{all.size}" if (counter += 1) % 100 == 0
      end
    end
    
    add_index :places, :country_id
  end

  def self.down
    remove_column :projects, :country_id
    remove_column :projects, :continent_id

    remove_column :project_versions, :short_description
    remove_column :project_versions, :country_id
    remove_column :project_versions, :continent_id

    remove_column :places, :country_id
    remove_index :places, :country_id
  end
end
