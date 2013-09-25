class AddStateToRecollection < ActiveRecord::Migration
  def change
    add_column :recollections, :state, :integer
  end
end
