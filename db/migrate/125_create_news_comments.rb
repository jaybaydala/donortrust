class CreateNewsComments < ActiveRecord::Migration
  def self.up
    create_table :news_comments do |t|
      t.references :user
      t.references :news_item
      t.text       :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :news_comments
  end
end
