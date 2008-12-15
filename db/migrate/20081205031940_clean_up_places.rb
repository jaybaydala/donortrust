class CleanUpPlaces < ActiveRecord::Migration
=begin

Before running this migration, please run the following SQL to make sure that 
there are no dependencies on the States, Districts and Regions that are just 
about to be deleted, i.e. the results of each SQL query should be 0.

If dependencies are found in anything other than the projects or 
project_versions table, please reassign them using the bus_admin website.

SELECT count(*)
FROM contacts con
  INNER JOIN places pla ON con.place_id = pla.id
  INNER JOIN place_types plt ON pla.place_type_id = plt.id
WHERE plt.name in ('State', 'District', 'Region');

SELECT count(*)
FROM place_flickr_images con
  INNER JOIN places pla ON con.place_id = pla.id
  INNER JOIN place_types plt ON pla.place_type_id = plt.id
WHERE plt.name in ('State', 'District', 'Region');

SELECT count(*)
FROM place_sectors con
  INNER JOIN places pla ON con.place_id = pla.id
  INNER JOIN place_types plt ON pla.place_type_id = plt.id
WHERE plt.name in ('State', 'District', 'Region');

SELECT count(*)
FROM place_you_tube_videos con
  INNER JOIN places pla ON con.place_id = pla.id
  INNER JOIN place_types plt ON pla.place_type_id = plt.id
WHERE plt.name in ('State', 'District', 'Region');

SELECT count(*)
FROM project_versions con
  INNER JOIN places pla ON con.place_id = pla.id
  INNER JOIN place_types plt ON pla.place_type_id = plt.id
WHERE plt.name in ('State', 'District', 'Region');

SELECT count(*)
FROM projects con
  INNER JOIN places pla ON con.place_id = pla.id
  INNER JOIN place_types plt ON pla.place_type_id = plt.id
WHERE plt.name in ('State', 'District', 'Region');

SELECT count(*)
FROM quick_fact_places con
  INNER JOIN places pla ON con.place_id = pla.id
  INNER JOIN place_types plt ON pla.place_type_id = plt.id
WHERE plt.name in ('State', 'District', 'Region');

=end

  def self.up
   
    # Make sure there is nothing in the database that points to a place that is 
    # a state / region / district
    ensure_contacts_point_to_cities
    ensure_place_flickr_images_point_to_cities
    ensure_place_sectors_point_to_cities
    ensure_place_you_tube_videos_point_to_cities
    ensure_projects_point_to_cities
    ensure_project_versions_point_to_cities
    ensure_quick_fact_places_versions_point_to_cities

    # Remove all the cities in the database that are not being referred to
    # by anything. Leave places of other types intact so that the database 
    # maintains referential integrity.
    # TODO: IS THERE A MORE 'RUBY-LIKE' WAY TO DO THIS?
    # TODO: IS THERE A MORE EFFICIENT WAY TO DO THIS IN SQL?
    puts 'Removing all cities in the DB that are not being used... (this will take a while)'   
    execute "
      DELETE FROM places
      WHERE id NOT IN (SELECT distinct(place_id) FROM contacts WHERE place_id IS NOT NULL)
      AND   id NOT IN (SELECT distinct(place_id) FROM place_flickr_images WHERE place_id IS NOT NULL)
      AND   id NOT IN (SELECT distinct(place_id) FROM place_sectors WHERE place_id IS NOT NULL)
      AND   id NOT IN (SELECT distinct(place_id) FROM place_you_tube_videos WHERE place_id IS NOT NULL)
      AND   id NOT IN (SELECT distinct(place_id) FROM project_versions WHERE place_id IS NOT NULL)
      AND   id NOT IN (SELECT distinct(place_id) FROM projects WHERE place_id IS NOT NULL)
      AND   id NOT IN (SELECT distinct(place_id) FROM quick_fact_places WHERE place_id IS NOT NULL)
      AND   place_type_id = 6"

    # Make the parent of each city its corresponding country (i.e. for each 
    # place X with place_type_id = 6, look for an ancestor Y such that 
    # place_type_id = 2. Update the table so that X.parent_id = Y.id)
    puts 'Making each remaining city have a parent of type country...'    
    Place.find(:all, :conditions => 'place_type_id = 6').each do |place|  
      ancestors = place.ancestors
      ancestors.each do |ancestor|
        if ancestor.place_type_id==2
          place.parent = ancestor
          place.save
          break
        end
      end
    end

    # Remove all remaining states, districts and regions from the database 
    # (i.e. delete from places where place_type_id in {3, 4, 5} )
    puts 'Removing all remaining states, districts and regions...'    
    Place.find(:all, :conditions => 'place_type_id = 3 OR place_type_id = 4 OR place_type_id = 5 ').each { |place| place.destroy }
    PlaceType.find(:all, :conditions => 'id = 3 OR id = 4 OR id = 5').each { |place_type| place_type.destroy }

=begin
    Use this SQL after to make sure things seem to make sense:

SELECT pla.id AS place_id, pla.name AS place_name, pt.name AS place_type, pla.parent_id AS parent_id, pla_parents.name AS parent_name, parent_pt.name AS parent_type
FROM places pla
  INNER JOIN place_types pt         ON pla.place_type_id   = pt.id
  LEFT OUTER JOIN places pla_parents     ON pla.parent_id       = pla_parents.id
  LEFT OUTER JOIN place_types parent_pt  ON pla_parents.place_type_id  = parent_pt.id
ORDER BY pla.place_type_id, pla.parent_id;

=end

  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the deleted data"
  end

  ##############################################################################

  # TODO: This should be static  
  private 
  def self.ensure_contacts_point_to_cities
    Contact.find(:all).each do |contact|
      ensure_entity_points_to_city(contact)
    end
    return
  end

  # TODO: This should be static  
  private 
  def self.ensure_place_flickr_images_point_to_cities
    PlaceFlickrImage.find(:all).each do |place_flickr_image|
      ensure_entity_points_to_city(place_flickr_image)
    end
    return
  end

  # TODO: This should be static  
  private 
  def self.ensure_place_sectors_point_to_cities
    PlaceSector.find(:all).each do |place_sector|
      ensure_entity_points_to_city(place_sector)
    end
    return
  end

  # TODO: This should be static  
  private 
  def self.ensure_place_you_tube_videos_point_to_cities
    PlaceYouTubeVideo.find(:all).each do |place_you_tube_video|
      ensure_entity_points_to_city(place_you_tube_video)
    end
    return
  end

  # TODO: This should be static  
  private 
  def self.ensure_projects_point_to_cities

    # Run some specific SQL to address a project that is pointing to a place 
    # called Koinadugu that should actually be a city.
    execute "UPDATE places SET place_type_id = 6 WHERE place_id = 2587;"

    Project.find(:all).each do |project|
      ensure_entity_points_to_city(project)
    end
    return
  end

  # TODO: This should be static  
  private 
  def self.ensure_project_versions_point_to_cities

    # Run some specific SQL to address project versions that are hooked up to 
    # states / regions / districts that have no city with the same name. Note 
    # that we can do this without intervention from Leif by simply looking at 
    # the current version of the project to see which city it is hooked up to.
    execute "UPDATE project_versions SET place_id = 31576 WHERE place_id = 1580;"

    ProjectVersion.find(:all).each do |project_version|
      ensure_entity_points_to_city(project_version)
    end
    return
  end

  # TODO: This should be static  
  private 
  def self.ensure_quick_fact_places_versions_point_to_cities
    QuickFactPlace.find(:all).each do |quick_fact_place|
      ensure_entity_points_to_city(quick_fact_place)
    end
    return
  end

  # TODO: This should be static
  private
  def self.ensure_entity_points_to_city(entity)
    # Examine the entity. If it is pointing at a State, District or Region,
    # make a note of the name and find a city of the same name belonging to the 
    # same country and repoint the project to that.

    place = entity.place

    if !place.nil? && (place.place_type.name == 'State' || place.place_type.name == 'District' || place.place_type.name == 'Region')
      # We've found a entity that is assigned to a place that is NOT a city
      msg = "" + entity.class.to_s + " " + entity.id.to_s + " is assigned to " + place.name + " (id=" + place.id.to_s + ") which is a " + place.place_type.name
      puts msg
      RAILS_DEFAULT_LOGGER.warn(msg);        

      # TODO: Why don't you reuse the code already written in the Place class?      
      # Find out which country contains the place that the entity has been assigned
      # to.
      currentCountry = nil;
      ancestors = place.ancestors
      ancestors.each do |ancestor|
        if ancestor.place_type_id==2
          currentCountry = ancestor
        end
      end

      # Every place must have a country as one of its ancestors (except 
      # countries themselves and continents) so if this one doesn't then 
      # there's something seriously wrong.
      raise Exception, place.name + " does not belong to any country." if currentCountry.nil?
      
      # Find a city in the database that has the same name as the entity's
      # currently assigned place but that also belongs to the same country as
      # the entity's currently assigned place.
      citiesWithSameName = Place.find(:all, :conditions => ['place_type_id = ? AND name=?', 6, place.name])
      newCity = Array.new        
      citiesWithSameName.each do |cityWithSameName|
        ancestors = cityWithSameName.ancestors
        ancestors.each do |ancestor|
          if ancestor.place_type_id == 2 && ancestor.id == currentCountry.id
            newCity.push(cityWithSameName)
          end
        end
      end

      # If we didn't find any, or found more than one, then something is wrong
      if newCity.length == 0 
        raise Exception, "There is no city called " + place.name + " in the country " + currentCountry.name + " so I don't know what place to assign to " + entity.class.to_s + " ID " + entity.id.to_s
      elsif newCity.length > 1 
        msg = "There are " + newCity.length.to_s + " cities called " + place.name + " in the country " + currentCountry.name + " so I don't know what place to assign to " + entity.class.to_s + " ID " + entity.id.to_s

        for foundPlace in newCity
          msg += ", city ID = " + foundPlace.id.to_s
        end
       
        raise Exception, msg
      end

      # Otherwise plough on with the reassignment
      entity.place = newCity[0]
      entity.save
      msg = "It has been reassigned to " + newCity[0].name + " (id=" + newCity[0].id.to_s + ") which is a " + newCity[0].place_type.name
      puts msg        
      RAILS_DEFAULT_LOGGER.warn(msg);        

    end

  end

  # This is a hack to make access to the project_versions table easier
  class ProjectVersion < ActiveRecord::Base
    belongs_to :place
  end

end
