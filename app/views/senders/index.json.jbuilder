json.array!(@senders) do |sender|
  json.extract! sender, :name, :sender_entity_id, :user_name, :password, :language, :mail_sent, :blocked
  json.url sender_url(sender, format: :json)
end
