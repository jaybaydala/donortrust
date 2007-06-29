class ProjectYouTubeVideosRel001 < ActiveRecord::Migration
  def self.up
    create_table "project_you_tube_videos", :force => true do |t|
      t.column :project_id,              :int
      t.column :you_tube_video_id,       :int
    end
  end

  def self.down
    drop_table "project_you_tube_videos"
  end
end
