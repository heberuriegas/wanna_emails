class ChangeProductNameLength < ActiveRecord::Migration
  def change
    change_column :prospects, :name, :string
    change_column :prospects, :address, :string
    change_column :prospects, :hours, :string
    change_column :products, :name, :string
    change_column :categories, :name, :string
  end
end
