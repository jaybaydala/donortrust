class ProjectFlickrImage < ActiveRecord::Base
  belongs_to :project, :touch => true
  validates_presence_of :project_id, :photo_id
  validate do |me|
    unless me.project( true )
      me.errors.add :project_id, 'does not exist'
    end
  end
  
  def exists?
    @exists ||= !!info
  end
  
  def owner
    @owner ||= { :nsid => info["owner"]["nsid"], :username => info["owner"]["username"], :realname => info["owner"]["realname"] } if exists?
  end
  
  def square
    @square ||= get_size('square')
  end

  def thumbnail
    @thumbnail ||= get_size('thumbnail')
  end

  def small
    @small ||= get_size('small')
  end

  def medium
    @medium ||= get_size('medium')
  end

  def medium_640
    @medium_640 ||= get_size('medium 640')
  end
  
  def large
    @large ||= get_size('large')
  end

  protected
    def flickr
      @flickr ||= FlickRaw::Flickr.new
    end

    def info
      begin
        @info ||= self.flickr.photos.getInfo(:photo_id => self.photo_id)
      rescue
        nil
      end
    end

    def get_size(desired_size)
      if exists? && size = self.sizes.detect{|size| size["label"].downcase == desired_size.downcase }
        {
          :url => size["url"], 
          :source => size["source"], 
          :width => size["width"], 
          :height => size["height"]
        }
      end
    end

    def sizes
      begin
        @sizes ||= self.flickr.photos.getSizes(:photo_id => self.photo_id)
      rescue
        nil
      end
    end
end
