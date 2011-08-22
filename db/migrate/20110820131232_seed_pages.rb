class SeedPages < ActiveRecord::Migration
  def self.up
    Page.rebuild!
    require Rails.root.join('db', 'seeds', 'about_us_pages')
    require Rails.root.join('db', 'seeds', 'get_involved_pages')
    require Rails.root.join('db', 'seeds', 'general_pages')
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
