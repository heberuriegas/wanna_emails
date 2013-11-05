class CreateSenderEntities < ActiveRecord::Migration
  def change
    create_table :sender_entities do |t|
      t.string :name
      t.string :address
      t.integer :port
      t.string :domain
      t.string :user_name
      t.string :password
      t.string :authentication
      t.boolean :enable_starttls_auto

      t.timestamps
    end
  end
end
