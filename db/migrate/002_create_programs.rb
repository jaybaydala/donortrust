class CreatePrograms < ActiveRecord::Migration
  def self.up
    create_table :programs do |t|
    end
  end

  def self.down
    drop_table :programs
  end
end
