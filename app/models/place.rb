class Place < ActiveRecord::Base

  acts_as_tree :order=>"name" , :forgien_key => "parent_id"

  file_column :file, :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")
  
  belongs_to :place_type
  belongs_to :sector
  has_many :quick_fact_places
  has_many :projects
  has_many :place_sectors
  has_many :groups
  has_many :place_flickr_images
  has_many :place_you_tube_videos

  validates_presence_of :name
  validates_presence_of :place_type_id
  validates_numericality_of :facebook_group_id, :allow_nil => true

  acts_as_textiled :description
  
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
  
  def self.full_location_string(place)
    full_name = ""
    #if place has no parents, return the name of the place.
    if place.parent_id.nil?
      full_name = place.name
    else
      parent = Place.find_by_id(place.parent_id)
      until parent.nil?
        full_name << "#{parent.name} > "
        unless parent.parent_id.nil?
          parent = Place.find_by_id(parent.parent_id)
        else
          parent = nil
        end
      end
      full_name << "#{place.name}"
    end
    full_name
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
  
  def Place.getPeerPlaces(place)
    return Place.find(:all, :conditions => ["parent_id = ?", place.parent_id])
  end
  
  def file_image?
    return false if !file?
    return true if self[:file].match /\.(jpg|gif|png)$/ 
    return false
  end
end
