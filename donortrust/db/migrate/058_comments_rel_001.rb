class CommentsRel001 < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :name, :string, :null => false
      t.column :email, :string, :null => false
      t.column :comment, :string, :null => false
      t.column :date, :datetime
    end
  end

  def self.down
    drop_table :comments
  end
end
