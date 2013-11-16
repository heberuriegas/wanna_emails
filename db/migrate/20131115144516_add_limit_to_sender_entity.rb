class AddLimitToSenderEntity < ActiveRecord::Migration
  def change
    add_column :sender_entities, :limit, :integer, default: 0
  end
end
