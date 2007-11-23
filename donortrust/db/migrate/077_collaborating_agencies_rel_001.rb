class CollaboratingAgenciesRel001 < ActiveRecord::Migration
  def self.up
    create_table :collaborating_agencies do |t|
      t.column :project_id,       :integer
      t.column :agency_name,      :string  
      t.column :responsibilities, :text     
    end
  end
  def self.down
    drop_table :collaborating_agencies
  end
end