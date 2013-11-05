class AddCountryCodeToRecollections < ActiveRecord::Migration
  def change
    add_column :recollections, :country_code, :string
  end
end
