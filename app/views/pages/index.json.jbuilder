json.array!(@pages) do |page|
  json.extract! page, :host, :uri
  json.url page_url(page, format: :json)
end
