class CreateRecollections < ActiveRecord::Migration
  def change
    create_table :recollections do |t|
      t.string :name
      t.datetime :date
      t.float :latitude
      t.float :longitude
      t.integer :goal
      t.references :user, index: true

      t.timestamps
    end
  end
end
