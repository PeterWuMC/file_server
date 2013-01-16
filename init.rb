require 'rubygems'

require 'sinatra'
require 'sinatra/json'
require 'sinatra/activerecord'

require 'json'
require 'base64'
require 'yaml'
require 'haml'

require_relative 'models/models'
require_relative 'models/shared_file'
require_relative 'config/initializer'
require_relative 'helpers/server_helper'

require_relative 'routes/routes'

class WuFileServer < Sinatra::Application

  set :database, "mysql2://#{db_settings["db_username"]}:#{db_settings["db_password"]}@#{db_settings["db_host"]}/#{db_settings["db_name"]}"

  before do
    @user_name   = params["user_name"]
    device_code  = params["device_code"]

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

  get '/*' do
    halt 403
  end

end