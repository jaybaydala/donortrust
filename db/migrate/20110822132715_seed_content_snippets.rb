class SeedContentSnippets < ActiveRecord::Migration
  def self.up
    require Rails.root.join('db', 'seeds', 'content_snippets')
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
