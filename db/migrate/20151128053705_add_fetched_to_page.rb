class AddFetchedToPage < ActiveRecord::Migration
  def change
    add_column :pages, :fetched, :boolean
  end
end
