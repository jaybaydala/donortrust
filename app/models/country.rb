class Country < ActiveRecord::Base
  belongs_to :continent
  has_many :regions, :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name
  


  def to_label  
    "#{name}"
  end
end
