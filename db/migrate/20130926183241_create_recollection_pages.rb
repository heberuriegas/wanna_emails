class CreateRecollectionPages < ActiveRecord::Migration
  def change
    create_table :recollection_pages do |t|
      t.references :recollection, index: true
      t.references :page, index: true
      t.integer :number_of_emails

      t.timestamps
    end
  end
end
