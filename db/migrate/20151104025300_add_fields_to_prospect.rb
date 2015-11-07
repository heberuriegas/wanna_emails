class AddFieldsToProspect < ActiveRecord::Migration
  def change
    add_column :prospects, :url, :string, limit: 255
    add_column :prospects, :country, :string, limit: 75
    add_column :prospects, :state, :string, limit: 75
  end
end
