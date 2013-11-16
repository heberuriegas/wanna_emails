class ChangeUserNameColumnToSenders < ActiveRecord::Migration
  def change
    rename_column :senders, :user_name, :email
  end
end
