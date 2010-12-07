class AddLayoutToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :layout, :string
    add_column :pages, :template, :string
  end

  def self.down
    remove_column :pages, :template
    remove_column :pages, :layout
  end
end
