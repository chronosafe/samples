json.array!(@decodes) do |decode|
  json.extract! decode, 
  json.url decode_url(decode, format: :json)
end
