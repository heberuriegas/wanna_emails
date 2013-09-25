class AddTimesToRecollection < ActiveRecord::Migration
  def change
    add_column :recollections, :starts_at, :datetime
    add_column :recollections, :ends_at, :datetime
  end
end
