class AddCountryShortcutToPlaces < ActiveRecord::Migration
  def self.up
    add_column :places, :country_id, :integer
    add_index :places, :country_id

    say_with_time "Adding country ID shortcuts to places. This will take up to an hour or more depending on the size of the Places table. Please have a pot of tea or two..." do
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
        
        puts "#{counter}/#{all.size}" if (counter += 1) % 1000 == 0
      end
    end
    
  end

  def self.down
    remove_index :places, :country_id
    remove_column :places, :country_id
  end
end
