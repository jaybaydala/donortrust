class RankValuesRel001 < ActiveRecord::Migration
  def self.up
    create_table :rank_values, :force => true do |t|
      t.column :rank_value,       :int
      t.column :file, :text
      t.column :deleted_at, :datetime
    end
  end

  def self.down
    drop_table :rank_values
  end
end
