class Place < ActiveRecord::Base

  acts_as_tree :order => "name" , :foreign_key => "parent_id"

  file_column :file, :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")
  
  belongs_to :place, :class_name => "Place", :foreign_key => "parent_id"
  has_many :places, :class_name => "Place", :foreign_key => "parent_id"
  
  belongs_to :place_type
  belongs_to :sector
  has_many :quick_fact_places
  has_many :projects
  has_many :place_sectors
  has_many :groups
  has_many :place_flickr_images
  has_many :place_you_tube_videos
  
  has_many :place_limits
  has_many :campaigns, :through => :place_limits
  belongs_to :parent_place, :class_name => "Place", :foreign_key => "parent_id"
  has_many :places, :class_name => "Place", :foreign_key => "parent_id"
  validates_presence_of :name
  validates_presence_of :place_type_id
  validates_numericality_of :facebook_group_id, :allow_nil => true

  acts_as_textiled :description
  
  is_indexed :fields => [
    {:field => 'name', :sortable => true},
    {:field => 'parent_id', :as => 'continent'}
    ],
    :conditions => 'place_type_id=2'

  
  def Place.getParentString(place)
    parentString = ""
    
    #only append name of parameter if it has children
    if Place.getChildCount(place) > 0
      parentString = place.name + " > "
    end
    
    while place.parent != nil
      place = place.parent
      parentString = place.name + " > " + parentString
    end
    
    return parentString    
  end
  
  # This method is here because I'm sure it's cheaper to query for a count
  #  than to populate the tree and count items.
  def Place.getChildCount(place)
        sql = ActiveRecord::Base.connection();
  sql.execute "SET autocommit=0";
  sql.begin_db_transaction
  value = sql.execute("SELECT count(name) FROM places WHERE parent_id = " + place.id.to_s).fetch_row[0].to_i;
  sql.commit_db_transaction
        return value;
  end
  
  def long_name
    result = self.name
    if self.parent != nil
      result = "#{self.parent.long_name} - #{self.name}"
    end
    result
  end
  
  def Place.getPeerPlaces(place)
    return Place.find(:all, :conditions => ["parent_id = ?", place.parent_id])
  end
  
  def file_image?
    return false if !file?
    return true if self[:file].match /\.(jpg|gif|png)$/ 
    return false
  end
  
  def country
    ancestors = self.ancestors
    ancestors.each do |ancestor|
      if ancestor.place_type_id==2
        return ancestor
      end
    end
  end
  
  def continent
    ancestors = self.ancestors
    ancestors.each do |ancestor|
      if ancestor.place_type_id==1
        return ancestor
      end
    end
  end
  
  def Place.projects(type_id, place_id, continent_id=nil)
    sel_projects = []
    @search = Ultrasphinx::Search.new(:class_names => 'Project', :per_page => Project.count)
    @search.run
    all_projects = @search.results
  
    all_projects.each do |project|
      if type_id==2
        if project.place.country.id == place_id.to_i
          sel_projects << project
        end
        
      end
      if type_id==1 
        if project.place.continent.id == place_id.to_i
          sel_projects << project
        end
        
      end
            
      #project.place.ancestors.each do |ancestor|
      #  if ancestor.place_type_id == type_id.to_i && ancestor.id == place_id.to_i 
      #    sel_projects << project
      #  end
      #end
    end
    return sel_projects
  end
  
  #just for use with ultrasphinx
  def Place.countries(continent_id)
      @search = Ultrasphinx::Search.new(:class_names => 'Place', :per_page => Place.count, :filters => {'continent' =>  continent_id})
      @search.run
      places = @search.results
      return places
  end

end
