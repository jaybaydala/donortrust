class Page < ActiveRecord::Base
  validates_presence_of :title, :permalink, :content
  has_many :wall_posts, :as => :postable, :dependent => :destroy
end