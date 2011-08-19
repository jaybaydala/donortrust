class AddPathToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :path, :string
  end

  def self.down
    remove_column :pages, :path
  end
end
