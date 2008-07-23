class CreateCauseLimits < ActiveRecord::Migration
  def self.up
    create_table :cause_limits do |t|
      t.references  :campaign
      t.references :cause

      t.timestamps
    end
  end

  def self.down
    drop_table :cause_limits
  end
end
