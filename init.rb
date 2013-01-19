require 'rubygems'

require 'sinatra'
require 'sinatra/json'
require 'sinatra/activerecord'

require 'json'
require 'base64'
require 'yaml'
require 'haml'

require 'RMagick'

require_relative 'models/models'
require_relative 'models/shared_file'
require_relative 'config/initializer'
require_relative 'helpers/server_helper'

require_relative 'routes/routes'

class WuFileServer < Sinatra::Application

  set :database, "mysql2://#{db_settings["db_username"]}:#{db_settings["db_password"]}@#{db_settings["db_host"]}/#{db_settings["db_name"]}"

  before do
    @user_name  = params["user_name"]
    device_code = params["device_code"]

    if !is_utility_path?
      @user = User.allow?(@user_name, device_code)
      halt 403 if !@user
      if request.path =~ %r{^/projects} && !(request.path =~ %r{/projects/list.json})
        project_key = request.path.scan(%r{^/projects/([^/]*)/}).flatten.first
        @project = @user.projects.find_by_key(project_key)
        halt 403 if !@project

        if request.path =~ %r{/(server_folders|server_files)/[^/]*(/|.json)}
          model, key = eval_folder_file_url
          key = "Lw==" if key == "initial"
          @full_path, @path = check_and_return_path_with_project(key, @project)

          raise Sinatra::NotFound if !@full_path || !(request.request_method.downcase == "post" || File.exist?(@full_path))
        end
      end
    end
  end

  post '/mobile/upload' do
    device   = @user.devices.find_by_device_code(params["device_code"])
    @project = @user.projects.find_by_name(@user.user_name)

    halt 500 if !device || !@project || !params['file']

    @key = Base64.strict_encode64("mobile/#{device.device_name}/")
    @full_path, @key = check_and_return_path_with_project(@key, @project)

    write_file(File.join(@full_path, params['file'][:filename]), params['file'][:tempfile].read)

    json(SharedFile.new(File.join(@full_path, params['file'][:filename]), @project), :encoder => :to_json, :content_type => :js)
  end

  get '/public/*' do
    puts params[:splat]
    puts SharedFile.decrypt_for_public params[:splat].first
  end

  get '/*' do
    halt 403
  end

end