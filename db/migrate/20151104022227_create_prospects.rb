class CreateProspects < ActiveRecord::Migration
  def change
    create_table :prospects do |t|
      t.string :name, limit: 150
      t.string :address, limit: 150
      t.string :hours, limit: 150
      t.references :category, index: true
      t.references :recollection_page, index: true

      t.timestamps
    end
  end
end
