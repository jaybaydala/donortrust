class ChangeFrendoDefaultTrue < ActiveRecord::Migration
  def self.up
    change_column_default(:subscriptions, :frendo, true)
  end

  def self.down
    change_column_default(:subscriptions, :frendo, false)
  end
end
