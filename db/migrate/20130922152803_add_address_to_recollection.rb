class AddAddressToRecollection < ActiveRecord::Migration
  def change
    add_column :recollections, :address, :string
  end
end
