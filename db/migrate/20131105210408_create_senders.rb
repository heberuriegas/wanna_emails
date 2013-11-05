class CreateSenders < ActiveRecord::Migration
  def change
    create_table :senders do |t|
      t.string :name
      t.references :sender_entity, index: true
      t.string :user_name
      t.string :password
      t.string :language
      t.integer :mail_sent, default: 0
      t.boolean :blocked, default: false

      t.timestamps
    end
  end
end
