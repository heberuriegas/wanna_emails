class AddUniquePagesToRecollections < ActiveRecord::Migration
  def change
    add_column :recollections, :unique_pages, :boolean, default: false
  end
end
