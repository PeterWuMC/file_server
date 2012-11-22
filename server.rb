require 'sinatra'
require 'sinatra/json'
require 'json'
require 'base64'

require_relative 'helpers/server_helper'


# .find(:all)
get '/files.json' do
  json(Dir["#{server_path}/**/*"].select{|v| File.file?(v)}.map{|v| {version: 1, path: v.gsub(/^#{server_path}/, "")}}, :encoder => :to_json, :content_type => :js)
end

# .download "/xxx/xxx/xxx.xx"
get '/files/download.json' do
  if params[:path]
    path = File.join(server_path, params[:path])
    if path && File.exist?(path)
      file = nil
      File.open(path, 'rb'){|f| file = f.read}

      json({path: params["path"], file: Base64.encode64(file)}, :encoder => :to_json, :content_type => :js)
    end
  end
end


get '/files/:path' do |path|
  raise "Unauthorised"
end

get '/*' do
  raise "Unauthorised"
end
