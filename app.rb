require 'rubygems'
require 'sinatra'
require 'base64'
require 'yaml'
require 'active_record'
require './models/url'
require 'json'

set :server, 'thin'

env = settings.environment
db_params = YAML::load((File.open('config/database.yml')))[env.to_s]
ActiveRecord::Base.establish_connection(db_params)

get '/:url' do
  url = Url.find_by_url(params[:url])
  if url
    redirect url.longUrl, 301
  else
    status 404
    "This is not the url you are looking for"
  end
end

get '/' do
  "Send a POST request to register a new URL."
end

post '/' do
  longUrl = clean_url(JSON.parse(request.body.read)["longUrl"])
  shortUrl = shorten_url(longUrl)
  url = Url.find_by(longUrl: longUrl)
  unless url.present?
  url = Url.create(longUrl: longUrl, url: shortUrl)
  end
  url = Url.find_or_create_by(longUrl: "http://#{longUrl}") do |created_url|
    created_url.url = shortUrl
  end
  content_type :json
  { url: "#{base_url}/#{url.url}" }.to_json
end

def clean_url(raw_url)
  raw_url = raw_url.to_s if raw_url.nil?
  cleaned_url = raw_url.strip
  cleaned_url = cleaned_url.gsub(/(https?:\/\/)|(www\.)/, "")
  cleaned_url = cleaned_url.split('/').map do |urlpart|
    if /\A([\w]{2})-([\w]{2})\z/.match?(urlpart)
      urlpart
    else
      urlpart.downcase
    end
  end.join('/')
  cleaned_url.slice!(-1) if '/' == cleaned_url[-1]
  cleaned_url
end

def shorten_url(longUrl)
  Base64.encode64(longUrl).split('').sample(6).join
end

def base_url
  @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
end
