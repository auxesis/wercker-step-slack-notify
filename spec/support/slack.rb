require 'rubygems'
require 'sinatra'
require 'pry'
require 'json'

$SLACK_REQUEST_QUEUE = []

class Slack < Sinatra::Base
  post '/500' do
    status 500
    "a random error"
  end

  post '/404' do
    status 404
  end

  post %r{/(\w+)_(\w+)} do |result, status|
    $SLACK_REQUEST_QUEUE << JSON.parse(params[:payload])
    status 200
  end
end
