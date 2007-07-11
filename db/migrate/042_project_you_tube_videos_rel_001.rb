class ProjectYouTubeVideosRel001 < ActiveRecord::Migration
  def self.up
    create_table "project_you_tube_videos", :force => true do |t|
      t.column :project_id, :integer
      t.column :you_tube_video_id, :integer
    end
  end

  def self.down
    drop_table "project_you_tube_videos"
  end
end
