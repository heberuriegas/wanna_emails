class AddLastSentToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :last_sent_at, :date
  end
end
