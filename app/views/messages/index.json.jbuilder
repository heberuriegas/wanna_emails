json.array!(@messages) do |message|
  json.extract! message, :subject, :text, :project_id
  json.url message_url(message, format: :json)
end
