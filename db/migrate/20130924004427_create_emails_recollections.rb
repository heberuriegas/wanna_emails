class CreateEmailsRecollections < ActiveRecord::Migration
  def change
    create_table :emails_recollections, id: false do |t|
        t.references :email
        t.references :recollection
    end
    add_index :emails_recollections, [:email_id, :recollection_id], unique: true
    add_index :emails_recollections, :email_id
  end
end
