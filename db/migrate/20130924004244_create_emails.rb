class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :address

      t.timestamps
    end

    add_index :emails, :address
  end
end
