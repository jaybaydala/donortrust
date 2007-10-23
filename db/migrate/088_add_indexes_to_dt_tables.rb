class AddIndexesToDtTables < ActiveRecord::Migration
  def self.up
    # places table
    add_index :places, :place_type_id
    add_index :places, :parent_id
    # projects table
    add_index :projects, :program_id
    add_index :projects, :project_status_id
    add_index :projects, :contact_id
    add_index :projects, :place_id
    add_index :projects, :partner_id
    add_index :projects, :frequency_type_id
    # groups_projects table
    add_index :groups_projects, [:project_id, :group_id]
    add_index :groups_projects, :group_id
    # projects_causes
    add_index :causes_projects, [:project_id, :cause_id]
    add_index :causes_projects, :cause_id
    # milestones
    add_index :milestones, :project_id
    add_index :milestones, :milestone_status_id
    # project_you_tube_videos
    add_index :project_you_tube_videos, :project_id
    add_index :project_you_tube_videos, :you_tube_video_id
    # project_flickr_images
    add_index :project_flickr_images, :project_id
    add_index :project_flickr_images, :flickr_image_id
    # ranks
    add_index :ranks, :rank_value_id
    add_index :ranks, :rank_type_id
    add_index :ranks, :project_id
    # investments
    add_index :investments, :user_id
    add_index :investments, :project_id
    add_index :investments, :group_id
    add_index :investments, :gift_id
    # wishlists
    add_index :wishlists, [:user_id, :project_id]
    add_index :wishlists, :project_id
    # key_measures
    add_index :key_measures, :project_id
    add_index :key_measures, :measure_id
    add_index :key_measures, :millennium_goal_id
    # deposits
    add_index :deposits, :gift_id
    add_index :deposits, :user_id
    # gifts
    add_index :gifts, :user_id
    add_index :gifts, :project_id
  end

  def self.down
    # places table
    remove_index :places, :place_type_id
    remove_index :places, :parent_id
    # projects table
    remove_index :projects, :program_id
    remove_index :projects, :project_status_id
    remove_index :projects, :contact_id
    remove_index :projects, :place_id
    remove_index :projects, :partner_id
    remove_index :projects, :frequency_type_id
    # groups_projects table
    remove_index :groups_projects, [:project_id, :group_id]
    remove_index :groups_projects, :group_id
    # projects_causes
    remove_index :causes_projects, [:project_id, :cause_id]
    remove_index :causes_projects, :cause_id
    # milestones
    remove_index :milestones, :project_id
    remove_index :milestones, :milestone_status_id
    # project_you_tube_videos
    remove_index :project_you_tube_videos, :project_id
    remove_index :project_you_tube_videos, :you_tube_video_id
    # project_flickr_images
    remove_index :project_flickr_images, :project_id
    remove_index :project_flickr_images, :flickr_image_id
    # ranks
    remove_index :ranks, :rank_value_id
    remove_index :ranks, :rank_type_id
    remove_index :ranks, :project_id
    # investments
    remove_index :investments, :user_id
    remove_index :investments, :project_id
    remove_index :investments, :group_id
    remove_index :investments, :gift_id
    # wishlists
    remove_index :wishlists, [:user_id, :project_id]
    remove_index :wishlists, :project_id
    # key_measures
    remove_index :key_measures, :project_id
    remove_index :key_measures, :measure_id
    remove_index :key_measures, :millennium_goal_id
    # deposits
    remove_index :deposits, :gift_id
    remove_index :deposits, :user_id
    # gifts
    remove_index :gifts, :user_id
    remove_index :gifts, :project_id
  end
end
