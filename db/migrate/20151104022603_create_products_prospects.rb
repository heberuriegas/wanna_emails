class CreateProductsProspects < ActiveRecord::Migration
  def change
    create_table :products_prospects do |t|
      t.references :product, index: true
      t.references :prospect, index: true
    end

    add_index :products_prospects, [:product_id, :prospect_id], unique: true
  end
end
