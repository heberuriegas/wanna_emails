class AddSearchByCityToRecollections < ActiveRecord::Migration
  def change
    add_column :recollections, :search_by_city, :boolean, default: false
  end
end
