class RanksRel001 < ActiveRecord::Migration
  def self.up
    create_table :ranks do |t|
      t.column :rank,           :string
      t.column :rank_type_id,   :int, :null => false
      t.column :project_id,     :int, :null => false
      t.column :deleted_at,     :datetime
      t.column :version,        :integer
    end
  end
  def self.down
    drop_table :ranks
  end
end