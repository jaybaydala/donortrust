class AddTitleAndTwitterAndFacebookToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :title, :string
    add_column :users, :twitter, :string
    add_column :users, :facebook, :string
    add_column :user_versions, :title, :string
    add_column :user_versions, :twitter, :string
    add_column :user_versions, :facebook, :string
  end

  def self.down
    remove_column :users, :facebook
    remove_column :users, :twitter
    remove_column :users, :title
    remove_column :user_versions, :facebook
    remove_column :user_versions, :twitter
    remove_column :user_versions, :title
  end
end
