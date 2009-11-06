class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :title
      t.string :permalink
      t.text :content
      t.boolean :active, :default => true

      t.timestamps
    end
    # Page.reset_column_information
    # Page.create!(:title => "UEnd.org – the first completely U: Powered Non-Profit", :permalink => "build_the_org")
  end

  def self.down
    drop_table :pages
  end
end
