class AddPhoneToSender < ActiveRecord::Migration
  def change
    add_column :senders, :phone, :string
  end
end
