require 'rubygems'
require 'sinatra'
require 'base64'
require 'yaml'
require 'active_record'
require './models/url'

set :server, 'thin'

env = settings.environment
db_params = YAML::load((File.open('config/database.yml')))[env.to_s]
ActiveRecord::Base.establish_connection(db_params)

get '/:url' do
  url = Url.find_by_url(params[:url])
  if url
    redirect url.longUrl
  else
    "This is not the url you are looking for"
  end
end

get '/' do
  "Send a POST request to register a new URL."
end

post '/' do
  longUrl = clean_url(params[:longUrl])
  shortUrl = shorten_url(longUrl)
  url = Url.find_or_create_by(url: shortUrl) do |created_url|
    created_url.longUrl = longUrl
  end
  "#{base_url}/#{url.url}"
end

def clean_url(raw_url)
  cleaned_url = raw_url.strip
  cleaned_url = cleaned_url.downcase.gsub(/(https?:\/\/)|(www\.)/, "")
  cleaned_url.slice!(-1) if '/' == cleaned_url[-1]
  'http://' + cleaned_url
end

def shorten_url(longUrl)
  Base64.encode64(longUrl)[0..6]
end

def base_url
  @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
end
