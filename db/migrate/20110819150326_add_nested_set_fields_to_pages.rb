class AddNestedSetFieldsToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :parent_id, :integer
    add_column :pages, :lft, :integer
    add_column :pages, :rgt, :integer
    add_column :pages, :path, :string
    Page.reset_column_information
    Page.rebuild!
  end

  def self.down
    remove_column :pages, :path
    remove_column :pages, :rgt
    remove_column :pages, :lft
    remove_column :pages, :parent_id
  end
end
