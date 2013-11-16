class CreateSentEmails < ActiveRecord::Migration
  def change
    create_table :sent_emails do |t|
      t.references :campaign, index: true
      t.references :email, index: true
      t.references :sender, index: true
      t.references :message, index: true
      t.date :sent_at

      t.timestamps
    end

    add_index :sent_emails, [:sent_at, :email_id, :sender_id], name: :index_sent_emails
  end
end
