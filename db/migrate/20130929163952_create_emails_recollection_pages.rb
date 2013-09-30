class CreateEmailsRecollectionPages < ActiveRecord::Migration
  def up
    drop_table :emails_recollections

    create_table :emails_recollection_pages, id: false do |t|
      t.references :email, index: true
      t.references :recollection_page, index: true
      t.primary_key [:email_id, :recollection_page_id]
    end

    add_index :emails_recollection_pages, [:email_id, :recollection_page_id], unique: true, name: 'index_emails_recollection_pages_unique'
  end

  def down
    drop_table :emails_recollection_pages

    create_table :emails_recollections, id: false do |t|
      t.references :email, index: true
      t.references :recollection
    end

    add_index :emails_recollections, [:email_id, :recollection_id], unique: true
  end
end
