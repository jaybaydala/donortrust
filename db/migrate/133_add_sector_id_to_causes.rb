class AddSectorIdToCauses < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE causes ADD sector_id INT(11) AFTER description"

    execute "UPDATE causes SET sector_id = 7 WHERE name = 'HIV/AIDS'"
    execute "UPDATE causes SET sector_id = 7 WHERE name = 'Malaria'"
    execute "UPDATE causes SET sector_id = 7 WHERE name = 'Infant Mortality'"
    execute "UPDATE causes SET sector_id = 7 WHERE name = 'Health Centers'"
    execute "UPDATE causes SET sector_id = 7 WHERE name = 'Medication'"
    execute "UPDATE causes SET sector_id = 4 WHERE name = 'Water Filtration'"
    execute "UPDATE causes SET sector_id = 4 WHERE name = 'Build Wells'"
    execute "UPDATE causes SET sector_id = 5 WHERE name = 'Gender Education'"
    execute "UPDATE causes SET sector_id = 1 WHERE name = 'Build Schools'"
    execute "UPDATE causes SET sector_id = 3 WHERE name = 'Enterprises'"
    execute "UPDATE causes SET sector_id = 3 WHERE name = 'Micro-finance'"
    execute "UPDATE causes SET sector_id = 11 WHERE name = 'Cereal Banks'"
    execute "UPDATE causes SET sector_id = 1 WHERE name = 'Classes/teaching'"
    execute "UPDATE causes SET sector_id = 1 WHERE name = 'School Supplies'"
    execute "UPDATE causes SET sector_id = 7 WHERE name = 'Health'"
    execute "UPDATE causes SET sector_id = 1 WHERE name = 'Education'"
    execute "UPDATE causes SET sector_id = 3 WHERE name = 'Economy'"
    execute "UPDATE causes SET sector_id = 2 WHERE name = 'Agriculture'"
    execute "UPDATE causes SET sector_id = 8 WHERE name = 'Infrastructure'"
    execute "UPDATE causes SET sector_id = 4 WHERE name = 'Water and Sanitation'"
    execute "UPDATE causes SET sector_id = 6 WHERE name = 'Community Development'"
    execute "UPDATE causes SET sector_id = 5 WHERE name = 'Gender Equality'"
    execute "UPDATE causes SET sector_id = 2 WHERE name = 'Agricultural Training'"
    execute "UPDATE causes SET sector_id = 2 WHERE name = 'Fertilizer'"
    execute "UPDATE causes SET sector_id = 2 WHERE name = 'Specific Crops'"
    execute "UPDATE causes SET sector_id = 9 WHERE name = 'Electricity'"
    execute "UPDATE causes SET sector_id = 8 WHERE name = 'Roads'"
    execute "UPDATE causes SET sector_id = 8 WHERE name = 'Buildings'"
    execute "UPDATE causes SET sector_id = 6 WHERE name = 'Community Development Training'"

    drop_table :causes_sectors
  end

  def self.down
    create_table :causes_sectors,  :id => false do |t|
      t.column :cause_id,     :integer
      t.column :sector_id,    :integer
    end

    remove_column :causes, :sector_id
  end
end
