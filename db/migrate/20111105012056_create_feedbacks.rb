class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.integer :user_id
      t.string :name
      t.string :email
      t.string :subject
      t.string :message
      t.boolean :resolved, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
