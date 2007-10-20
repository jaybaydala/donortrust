class Place < ActiveRecord::Base

  acts_as_tree :order=>"name"  

  file_column :file, :web_root => "images/bus_admin/uploads/", :root_path => File.join(RAILS_ROOT, "public/images/bus_admin/uploads")
  
  belongs_to :place_type
  belongs_to :sector
  has_many :quick_fact_places
  has_many :projects
  has_many :place_sectors
  has_many :groups
  
  validates_presence_of :name
  validates_presence_of :place_type_id
  
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
  
  def Place.getPeerPlaces(place)
    return Place.find(:all, :conditions => ["parent_id = ?", place.parent_id])
  end
  
  def file_image?
    return true if file? && file.match /\.(jpg|gif|png)$/
    return false
  end
end
