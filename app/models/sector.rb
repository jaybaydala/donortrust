class Sector < ActiveRecord::Base
  acts_as_paranoid
  
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :causes
  
  has_many :place_sectors
  has_many :places , :through => :place_sectors
  has_many :quick_fact_sectors   
     
  validates_presence_of :name
  validates_uniqueness_of :name

  
  #ultrasphinx indexer
  #is_indexed :fields => [
   # {:field => 'name', :sortable => true},
  #  {:field => 'description', :sortable => true}
    #],
   #:conditions => "sectors.deleted_at IS NULL"
#  def project_count
#    return projects.count
#  end

end
