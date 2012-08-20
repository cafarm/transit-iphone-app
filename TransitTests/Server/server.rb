#!/usr/bin/env ruby
# Transit Test Server
# Provides a simple HTTP server for retrieving payloads stored in
# the Fixtures/ subdirectory.

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'

configure do
  enable :logging, :dump_errors
  set :public_dir, Proc.new { File.expand_path(File.join(root, '../Fixtures')) }
end

def render_fixture(filename)
  send_file File.join(settings.public_folder, filename)
end

get '/ws/plan' do
  content_type 'application/json'
  render_fixture('tripPlanResponse.json')
end

get '/place/autocomplete/json' do
  sleep 4
  content_type 'application/json'
  render_fixture('autocompleteResponse.json')
end

get '/place/details/json' do
  content_type 'application/json'
  render_fixture('detailsResponse.json')
end