class CreateContentSnippets < ActiveRecord::Migration
  def self.up
    create_table :content_snippets do |t|
      t.string :title
      t.string :slug
      t.text :body
      t.boolean :active
      t.timestamps
    end
  end

  def self.down
    drop_table :content_snippets
  end
end
