class AddSearchToRecollection < ActiveRecord::Migration
  def change
    add_column :recollections, :search, :string
  end
end
