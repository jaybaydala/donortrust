class AddActiveToPages < ActiveRecord::Migration
  def self.up
    # keep the existing pages as non-active
    add_column :pages, :active, :boolean, :default => false
    # now make future pages active by default
    change_column_default :pages, :active, true
  end

  def self.down
    remove_column :pages, :active
  end
end
