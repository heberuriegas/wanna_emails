class AddFullUserNameToSenderEntities < ActiveRecord::Migration
  def change
    add_column :sender_entities, :full_user_name, :boolean, default: false
  end
end
