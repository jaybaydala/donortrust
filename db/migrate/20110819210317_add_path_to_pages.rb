class AddPathToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :path, :string
    Page.reset_column_information
    # load the paths
    Page.all.each(&:save)
  end

  def self.down
    remove_column :pages, :path
  end
end
