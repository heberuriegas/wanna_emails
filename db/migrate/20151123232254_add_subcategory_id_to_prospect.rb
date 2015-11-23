class AddSubcategoryIdToProspect < ActiveRecord::Migration
  def change
    rename_column :prospects, :category_id, :subcategory_id
    add_reference :prospects, :category, index: true
  end
end
