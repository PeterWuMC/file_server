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
      unrecognized_credential if !@user
      if request.path =~ %r{^/projects} && !(request.path =~ %r{/projects/list.json})
        project_key = request.path.scan(%r{^/projects/([^/]*)/}).flatten.first
        @project = @user.projects.find_by_key(project_key)
        project_not_found if !@project

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

    incomplete_data_provided if !device || !@project || !params['file']

    @key = Base64.strict_encode64("mobile/#{device.device_name}/")
    @full_path, @key = check_and_return_path_with_project(@key, @project)

    if File.exist?(@full_path)
      ext      = File.extname(@full_path)
      dir      = File.dirname(@full_path)
      filename = File.basename(@full_path).scan(%r{(.*)#{ext}}).flatten.first
      version  = 0
      Dir["#{File.join(dir, filename)}*#{ext}"].each do |f|
        tmp_version = File.basename(f).scan(%r{^#{filename}\((\d)\)#{ext}$}).flatten.first
        tmp_version = tmp_version.to_i if tmp_version
        version = tmp_version if tmp_version > version
      end
      version += 1
      @full_path = "#{File.join(dir, filename)}(#{version})#{ext}"
    end
    write_file(File.join(@full_path, params['file'][:filename]), params['file'][:tempfile].read)

    json(SharedFile.new(File.join(@full_path, params['file'][:filename]), @project), :encoder => :to_json, :content_type => :js)
  end

  get '/public/*' do
    file = SharedFile.decrypt_for_public params[:splat].first
    file_folder_not_found unless file

    send_file file
  end

  get '/*' do
    page_is_not_authorized
  end

end