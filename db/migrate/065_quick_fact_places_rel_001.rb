class QuickFactPlacesRel001 < ActiveRecord::Migration
  def self.up
      create_table :quick_fact_places do |t|
        t.column :quick_fact_id,      :int
        t.column :description,        :string
        t.column :place_id,           :int
      end
  end

  def self.down
      drop_table :quick_fact_places
  end
end

