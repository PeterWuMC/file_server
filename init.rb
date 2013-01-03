require 'rubygems'

require 'sinatra'
require 'sinatra/json'
require 'sinatra/activerecord'

require 'json'
require 'base64'
require 'yaml'

require_relative 'models/models'
require_relative 'config/initializer'
require_relative 'helpers/server_helper'

set :database, "mysql2://#{db_settings["db_username"]}:#{db_settings["db_password"]}@#{db_settings["db_host"]}/#{db_settings["db_name"]}"

before do
  @user_name   = params["user_name"]
  device_code  = params["code"]

  if !is_registration_path?
    halt 403 if !User.allow?(@user_name, device_code)
  end
end

post '/registration' do
  device      = nil
  password    = params["password"]
  device_name = params["device_name"]
  device_code = params["device_code"]

  if @user_name && password && device_code
    user   = User.find_by_user_name(@user_name).try(:authenticate, password)
    halt 403 unless user
    device = user.find_or_create_device device_code, device_name
  else
    halt 403
  end
  status 202 # ACCEPTED
  json({key: device.device_code}, :encoder => :to_json, :content_type => :js)
end

post '/registration/check' do
  device      = nil
  device_code = params["code"]

  user = User.find_by_user_name(@user_name)
  halt 403 if !user || !user.devices.find_by_device_code(device_code)

  status 200
end

get %r{^/folder/(.*)/list.json$} do |key|
  key = "Lw==" if key == "initial"
  full_path, path = check_and_return_path(key)

  json(Dir["#{full_path}/*"].map{|v| {
    type:        File.file?(v) ? "file" : "folder",
    name:        File.basename(v),
    path:        v.gsub!(/^#{server_path}\//, ""),
    key:         Base64.strict_encode64(v),
  }}.sort_by{|v| v[:type]}.reverse!, :encoder => :to_json, :content_type => :js)
end

put %r{^/folder/(.*)/upload.json$} do |key|
  key = "Lw==" if key == "initial"
  full_path, path = check_and_return_path(key)
  halt 500 if !params['file']
  write_file(File.join(full_path, params['file'][:filename]), params['file'][:tempfile])
end



# ###########################
#      RESTFul
# ###########################

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

get %r{^/server_files/(.*)/download$} do |key|
  full_path, path = check_and_return_path(key)

  send_file(full_path, :disposition => 'attachment', :filename => File.basename(full_path))
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

