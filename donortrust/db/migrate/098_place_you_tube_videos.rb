class PlaceYouTubeVideos < ActiveRecord::Migration
  def self.up
    create_table :place_you_tube_videos do |t|
      t.column :place_id, :integer
      t.column :you_tube_id, :string
    end
  end

  def self.down
    drop_table :place_you_tube_videos
  end
end
