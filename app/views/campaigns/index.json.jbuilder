json.array!(@campaigns) do |campaign|
  json.extract! campaign, :name, :project_id, :user_id
  json.url campaign_url(campaign, format: :json)
end
