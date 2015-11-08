class AddPostalCodeToProspect < ActiveRecord::Migration
  def change
    add_column :prospects, :postal_code, :string
  end
end
