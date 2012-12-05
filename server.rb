require 'sinatra'
require 'sinatra/json'
require 'json'
require 'base64'

require_relative 'helpers/server_helper'

# .find(:all)
get '/files.json' do
  json(Dir["#{server_path}/**/*"].select{|v| File.file?(v)}.map{|v| {last_update: File.mtime(v), path: v.gsub(/^#{server_path}\//, "")}}, :encoder => :to_json, :content_type => :js)
end

# .find(:path).get(:download)
get %r{^/files/(.*)/download\.json$} do |path|
  puts "****", path
  file_path = File.join(server_path, path)
  if file_path && File.exist?(file_path)
    file = nil
    File.open(file_path, 'rb'){|f| file = f.read}

    json({path: path, file: Base64.encode64(file)}, :encoder => :to_json, :content_type => :js)
  end
end

#.find(:path)
get %r{^/files/(.*)\.json$} do |path|
  file_path = File.join(server_path, path)
  if file_path && File.exist?(file_path)
    json({path: path, last_update: File.mtime(file_path)}, :encoder => :to_json, :content_type => :js)
  end
end


get '/*' do
  raise "Unauthorised"
end