class CreateWallPosts < ActiveRecord::Migration
  def self.up
    create_table :wall_posts do |t|
      t.references  :postable, :polymorphic => true
      t.references  :user
      t.text        :wall_text
      t.timestamps
    end
  end

  def self.down
    drop_table :wall_posts
  end
end
