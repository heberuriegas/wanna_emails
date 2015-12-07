class AddNameLabelToRecollection < ActiveRecord::Migration
  def change
    add_column :recollections, :name_label, :string
  end
end
