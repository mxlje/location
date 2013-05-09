require 'sinatra'
require 'yaml'
require 'uri'
require 'open-uri'
require 'json'

before do
  headers "Access-Control-Allow-Origin" => "*"
  headers "Vary" => "Accept-Encoding"
  headers "Vary" => "Accept-Encoding"
  headers "Cache-Control" => "max-age=3600"
  headers "Expires" => "access plus 2 weeks"
end

get '/location.json' do
  content_type :json

  # load dropbox file
  from_dropbox = YAML::load(
  	open(ENV['DROPBOX_URL'])
  )

  # concatenate lat & long for call
  lat_long = from_dropbox['lat'].to_s + ',' + from_dropbox['long'].to_s

  # generate uri for forecast call
  forecast_request_uri = 'https://api.forecast.io/forecast/'
  forecast_request_uri << ENV['FORECAST_PRIVATE_KEY']
  forecast_request_uri << '/'
  forecast_request_uri << lat_long

  # prepare for call, exclude useless stuff
  uri = URI.parse(forecast_request_uri)
  params = {
    exclude: "minutely,hourly,daily,alerts,flags",
    units: "si"
  }
  uri.query = URI.encode_www_form( params )

  # get data
  forecast_return = JSON.parse(uri.open.read)

  # produce final output
  res = {}
  res['city'] = from_dropbox['city']
  res['weather'] = forecast_return['currently']['summary']
  res['temperature'] = forecast_return['currently']['temperature']

  res.to_json
end