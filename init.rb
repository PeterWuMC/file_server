require 'rubygems'

require 'sinatra'
require 'sinatra/json'
require 'sinatra/activerecord'

require 'json'
require 'base64'
require 'yaml'

require_relative 'models/models'
require_relative 'models/shared_file'
require_relative 'config/initializer'
require_relative 'helpers/server_helper'

set :database, "mysql2://#{db_settings["db_username"]}:#{db_settings["db_password"]}@#{db_settings["db_host"]}/#{db_settings["db_name"]}"

before do
  @user_name   = params["user_name"]
  device_code  = params["device_code"]

  if !is_registration_path?
    @user = User.allow?(@user_name, device_code)
    halt 403 if !@user
    if request.path =~ %r{^/projects} && !(request.path =~ %r{/projects/list.json})
      project_key = request.path.scan(%r{^/projects/([^/]*)/}).flatten.first
      @project = @user.projects.find_by_key(project_key)
      halt 403 if !@project

      if request.path =~ %r{/(server_folders|server_files)/([^/]*)/}
        model, key = eval_folder_file_url
        key = "Lw==" if key == "initial"
        @full_path, @path = check_and_return_path_with_project(key, @project)
      end
    end
  end
end

post '/registration' do
  device      = nil
  password    = params["password"]
  device_name = params["device_name"]
  device_id   = params["device_id"]

  if @user_name && password && device_id
    user   = User.find_by_user_name(@user_name).try(:authenticate, password)
    halt 403 unless user
    device = user.find_or_create_device device_id, device_name
  else
    halt 403
  end
  status 202 # ACCEPTED
  json({device_code: device.device_code}, :encoder => :to_json, :content_type => :js)
end

post %r{^/registration/check$} do
  device      = nil
  device_code = params["device_code"]

  user = User.find_by_user_name(@user_name)
  halt 403 if !user || !user.devices.find_by_device_code(device_code)

  status 200
end

get %r{/projects/list.json} do
  json(@user.projects.all.map(&:to_h), :encoder => :to_json, :content_type => :js)
end

get %r{^/projects/[^/]*/server_folders/[^/]*/list.json$} do
  json(Dir["#{@full_path}/*"].map{|v|
    SharedFile.new(v, @project)
  }.sort_by{|v| v.type}.reverse!, :encoder => :to_json, :content_type => :js)
end

post %r{^/projects/[^/]*/server_folders/[^/]*/upload$} do
  halt 500 if !params['file']
  write_file(File.join(@full_path, params['file'][:filename]), params['file'][:tempfile].read)

  json(SharedFile.new(@full_path, @project), :encoder => :to_json, :content_type => :js)
end

#.delete(:key)
delete %r{^/projects/[^/]*/server_files/[^/]*.json$} do
  File.delete(@full_path)
end

get %r{^/projects/[^/]*/server_files/[^/]*/download$} do
  send_file(@full_path, :disposition => 'attachment', :filename => File.basename(@full_path))
end


# # .find(:all)
# get %r{/project/(.*)/server_files.json} do |project_key|
#   json(Dir["#{server_path}/**/*"].select{|v| File.file?(v)}.map{|v|
#     SharedFile.new(v)
#   }, :encoder => :to_json, :content_type => :js)
# end

# # .find(:key).get(:download)
# get %r{^/server_files/(.*)/download\.json$} do |key|
#   full_path, path = check_and_return_path(key)

#   file = nil
#   File.open(full_path, 'rb'){|f| file = f.read}

# # TODO
#   json({key: key, path: path, file_content: Base64.encode64(file)}, :encoder => :to_json, :content_type => :js)
# end

# #.find(:key)
# get %r{^/server_files/(.*)\.json$} do |key|
#   full_path, path = check_and_return_path(key)

#   json(SharedFile.new(full_path), :encoder => :to_json, :content_type => :js)
# end

# #.find(:key).update_attributes(:xxxx, yyyy)
# put %r{^/server_files/(.*)\.json$} do |key|
#   full_path, path = check_and_return_path(key)

#   server_file  = JSON.parse(request.body.read)["server_file"]

#   path         = server_file["path"]
#   file_content = Base64.decode64(server_file["file_content"])
#   write_file(full_path, file_content)

#   status 200
# end

# #.new(:xxx => yyy)
# post '/server_files.json' do
#   server_file  = JSON.parse(request.body.read)["server_file"]

#   path         = server_file["path"]
#   full_path    = File.join(server_path, path)
#   file_content = Base64.decode64(server_file["file_content"])
#   write_file(full_path, file_content)

#   status 200
# end


get '/*' do
  halt 403
end

