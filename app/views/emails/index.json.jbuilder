json.array!(@emails) do |email|
  json.extract! email, :address
  json.url email_url(email, format: :json)
end
