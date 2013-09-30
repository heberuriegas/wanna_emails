class ChangeNumberOfEmailsFromRecollectionPages < ActiveRecord::Migration
  def up
    rename_column :recollection_pages, :number_of_emails, :emails_recollection_pages_count
    change_column :recollection_pages, :emails_recollection_pages_count, :integer, :default => 0
  end

  def down
    rename_column :recollection_pages, :emails_recollection_pages_count, :number_of_emails
  end
end
