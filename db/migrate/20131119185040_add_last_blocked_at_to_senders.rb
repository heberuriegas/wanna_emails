class AddLastBlockedAtToSenders < ActiveRecord::Migration
  def change
    add_column :senders, :last_blocked_at, :datetime
  end
end
