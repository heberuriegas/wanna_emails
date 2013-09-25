json.array!(@recollections) do |recollection|
  json.extract! recollection, :name, :date, :latitude, :longitude, :goal, :user_id
  json.url recollection_url(recollection, format: :json)
end
