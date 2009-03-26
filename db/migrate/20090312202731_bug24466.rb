class Bug24466 < ActiveRecord::Migration
  def self.up

    nicaraguaToKeep = Place.find_by_id(102)
    nicaraguaToDelete = Place.find_by_id(180218)

    # Reassign Pamkawas to a parent id 102 (and make its corresponding country id 102 as well)
    puts 'Repointing Pamkawas...'    
    pamkawas = Place.find_by_id(180233)
    pamkawas.parent_id = nicaraguaToKeep.id
    pamkawas.country_id = nicaraguaToKeep.id
    pamkawas.save

    # Change the parent of the real Nicaragua to belong to Central America (id 180209) instead of North America
    puts 'Repointing real Nicaragua to real parent...'    
    centralAmerica = Place.find_by_id(180209)
    nicaraguaToKeep.parent_id = centralAmerica.id
    nicaraguaToKeep.save

    # Change all quick_fact_places entries that point at place_id 180218 to point to 102
    puts 'Repointing quick fact places...'    
    QuickFactPlace.find(:all, :conditions => 'place_id = ' + nicaraguaToDelete.id.to_s).each do |quickFactPlace|  
      quickFactPlace.place_id = nicaraguaToKeep.id
      quickFactPlace.save
    end

    # Delete the bogus Nicaragua that has id 180218
    puts 'Deleting bogus Nicaragua...'    
    Place.delete(nicaraguaToDelete.id)

    # Repoint any projects, project version and places that reference the bogus Nicaragua in their country_id column to the real Nicaragua
    puts 'Repointing projects...'    
    Project.find(:all, :conditions => 'country_id = ' + nicaraguaToDelete.id.to_s).each do |project|  
      project.country_id = nicaraguaToKeep.id
      project.save
    end
    
    #ProjectVersion.find(:all, :conditions => 'country_id = ' + nicaraguaToDelete.id.to_s).each do |projectVersion|  
    #  projectVersion.country_id = nicaraguaToKeep.id
    #  projectVersion.save
    #end
    # The above code doesn't work because there's no project_version.rb model for some reason, so I'm taking the direct approach instead
    puts 'Repointing project versions...'    
    execute 'UPDATE project_versions SET country_id = ' + nicaraguaToKeep.id.to_s + ' WHERE country_id = ' + nicaraguaToDelete.id.to_s + ';'
    
    puts 'Repointing places...'    
    Place.find(:all, :conditions => 'country_id = ' + nicaraguaToDelete.id.to_s).each do |place|  
      place.country_id = nicaraguaToKeep.id
      place.save
    end
    
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the deleted data"
  end
end
