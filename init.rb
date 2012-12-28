require 'rubygems'
# require File.expand_path(File.dirname(__FILE__) + '/lib/config')
require 'sinatra'
require 'sinatra/json'
require 'json'
require 'base64'
require 'yaml'

require_relative 'helpers/server_helper'

get %r{^/folder/(.*)/list.json$} do |key|
  key = "Lw==" if key == "initial"
  full_path, path = check_and_return_path(key)

  json(Dir["#{full_path}/*"].map{|v| {
    type:        File.file?(v) ? "file" : "folder",
    name:        File.basename(v),
    path:        v.gsub!(/^#{server_path}\//, ""),
    key:         Base64.strict_encode64(v),
  }}, :encoder => :to_json, :content_type => :js)
end

# .find(:all)
get '/server_files.json' do
  json(Dir["#{server_path}/**/*"].select{|v| File.file?(v)}.map{|v| {
    last_update: File.mtime(v).utc,
    path:        v.gsub!(/^#{server_path}\//, ""),
    key:         Base64.strict_encode64(v)
  }}, :encoder => :to_json, :content_type => :js)
end

# .find(:key).get(:download)
get %r{^/server_files/(.*)/download\.json$} do |key|
  full_path, path = check_and_return_path(key)

  file = nil
  File.open(full_path, 'rb'){|f| file = f.read}

  json({key: key, path: path, file_content: Base64.encode64(file)}, :encoder => :to_json, :content_type => :js)
end

#.find(:key)
get %r{^/server_files/(.*)\.json$} do |key|
  full_path, path = check_and_return_path(key)

  json({key: key, path: path, last_update: File.mtime(full_path).utc}, :encoder => :to_json, :content_type => :js)
end

#.find(:key).update_attributes(:xxxx, yyyy)
put %r{^/server_files/(.*)\.json$} do |key|
  full_path, path = check_and_return_path(key)

  server_file  = JSON.parse(request.body.read)["server_file"]

  path         = server_file["path"]
  file_content = Base64.decode64(server_file["file_content"])
  write_file(full_path, file_content)

  status 200
end

#.delete(:key)
delete %r{^/server_files/(.*)\.json$} do |key|
  full_path, path = check_and_return_path(key)
  File.delete(full_path)

  status 200
end

#.new(:xxx => yyy)
post '/server_files.json' do
  server_file  = JSON.parse(request.body.read)["server_file"]

  path         = server_file["path"]
  full_path    = File.join(server_path, path)
  file_content = Base64.decode64(server_file["file_content"])
  write_file(full_path, file_content)

  status 200
end


get '/*' do
  halt 403
end

