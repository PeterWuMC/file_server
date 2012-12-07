require 'sinatra'
require 'sinatra/json'
require 'json'
require 'base64'

require_relative 'helpers/server_helper'

# .find(:all)
get '/server_files.json' do
  json(Dir["#{server_path}/**/*"].select{|v| File.file?(v)}.map{|v| {last_update: File.mtime(v), path: v.gsub(/^#{server_path}\//, "")}}, :encoder => :to_json, :content_type => :js)
end

# .find(:path).get(:download)
get %r{^/server_files/(.*)/download\.json$} do |path|
  file_path = File.join(server_path, path)
  if file_path && File.exist?(file_path)
    file = nil
    File.open(file_path, 'rb'){|f| file = f.read}

    json({path: path, file_content: Base64.encode64(file)}, :encoder => :to_json, :content_type => :js)
  else
    raise Sinatra::NotFound
  end
end

#.find(:path)
get %r{^/server_files/(.*)\.json$} do |path|
  file_path = File.join(server_path, path)
  if file_path && File.exist?(file_path)
    json({path: path, last_update: File.mtime(file_path)}, :encoder => :to_json, :content_type => :js)
  else
    raise Sinatra::NotFound
  end
end


get '/*' do
  raise "Unauthorised"
end
