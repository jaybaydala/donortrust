class AddCountryAndContinentShortcutsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :continent_id, :integer
    add_column :projects, :country_id, :integer

    add_column :project_versions, :short_description, :string, :limit => 255
    add_column :project_versions, :continent_id, :integer
    add_column :project_versions, :country_id, :integer

    say_with_time "Adding country and continent ID shortcuts to projects..." do
      Project.find(:all).each do |p|
        # find the country through place shortcuts
        country = Place.find(p.place.country_id)
        
        p.country_id = country.id
        p.continent_id = country.parent_id
        
        p.save!
      end
    end
  end

  def self.down
    remove_column :projects, :country_id
    remove_column :projects, :continent_id

    remove_column :project_versions, :short_description
    remove_column :project_versions, :country_id
    remove_column :project_versions, :continent_id
  end
end
