class AddCountryShortcutToPlaces < ActiveRecord::Migration
  def self.up
#    add_column :places, :country_id, :integer
#    add_index :places, :country_id

#    Place.reset_column_information

#    say_with_time "Adding country ID shortcuts to places. This will take up to an hour or more depending on the size of the Places table. Please have a pot of tea or two..." do

#      puts "* Assigning countries to themselves"
#      counter = 0
#      countries = Place.find(:all, :conditions => "place_type_id = 2 AND parent_id is not NULL AND country_id is NULL")
#      puts "found #{countries.size} countries"
#      countries.each do |c|
#        c.country_id = c.id
#        c.save!
#        puts "#{counter}/#{countries.size}" if (counter += 1) % 10 == 0
#      end

#      puts "* Assigning countries to states"
#      counter = 0
#      states = Place.find(:all, :conditions => "place_type_id = 3 AND parent_id is not NULL AND country_id is NULL")
#      puts "found #{states.size} states"
#      states.each do |s|
#        if s.parent.place_type_id == 2
#          s.country_id = s.parent_id
#          s.save!
#        end
#        puts "#{counter}/#{states.size}" if (counter += 1) % 100 == 0
#      end

#      puts "* Assigning countries to districts"
#      counter = 0
#      districts = Place.find(:all, :conditions => "place_type_id = 4 AND parent_id is not NULL AND country_id is NULL")
#      puts "found #{districts.size} districts"
#      districts.each do |d|
#        if d.parent.country_id
#          d.country_id = d.parent.country_id
#          d.save!
#        end
#        puts "#{counter}/#{districts.size}" if (counter += 1) % 100 == 0
#      end

#      puts "* Assigning countries to regions"
#      counter = 0
#      regions = Place.find(:all,
#                       :conditions => "place_type_id = 5 AND parent_id is not NULL AND country_id is NULL")
#      puts "found #{regions.size} regions"
#      regions.each do |r|
#        if r.parent.country_id
#          r.country_id = r.parent.country_id
#          r.save!
#        end
#        puts "#{counter}/#{regions.size}" if (counter += 1) % 100 == 0
#      end

#      puts "* Assigning countries to cities"
#      counter = 0
#      cities = Place.find(:all,
#                       :conditions => "place_type_id = 6 AND parent_id is not NULL AND country_id is NULL")
#      puts "found #{cities.size} cities"
#      cities.each do |c|
#        if c.parent.country_id
#          c.country_id = c.parent.country_id
#          c.save!
#        end
#        puts "#{counter}/#{cities.size}" if (counter += 1) % 1000 == 0
#      end

      #catch all remaining
#      puts "* Assigning countries to any remaining db entries"
#      counter = 0
#      remaining = Place.find(:all,
#                       :conditions => "place_type_id != 1 AND place_type_ID != 2 AND parent_id is not NULL AND country_id is NULL")
#      puts "found #{remaining.size} remaining entries"
#      remaining.each do |p|
#        # find country
#        temp = p.parent
#        while temp.place_type.id != 2 and temp.parent and not temp.country_id
#          temp = temp.parent
#        end
#
#        # save shortcut to country
#        if temp.parent
#          p.country_id = temp.country_id || temp.id
#          p.save!
#        end

#        puts "#{counter}/#{remaining.size}" if (counter += 1) % 1000 == 0
#      end
#    end
  end

  def self.down
#    remove_index :places, :country_id
#    remove_column :places, :country_id
  end

end
