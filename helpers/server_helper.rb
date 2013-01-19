require 'yaml'

helpers do

  def is_utility_path?
    # !(request.path =~ %r{^(?!/registration)})
    request.path =~ %r{^/(registration|password_reset|public)} ? true : false
  end

  def eval_folder_file_url
    model, key = request.path.scan(%r{/(server_folders|server_files)/([^/]*)(/|.json)}).flatten
    return model, key
  end

  def check_and_return_path_with_project key, project
    path      = Base64.strict_decode64(key)
    base_path = File.join(server_path, project.name)

    full_path = (path == "/") ? base_path : File.join(base_path, path)
    return full_path, path
  rescue
    raise Sinatra::NotFound
  end

  def check_and_return_path key
    path      = Base64.strict_decode64(key)
    full_path = (path == "/") ? server_path : File.join(server_path, path)
    return full_path, path
  rescue
    raise Sinatra::NotFound
  end


  # TODO: get this from file_manager
  def create_folders_for full_path
    full_path = File.dirname(full_path)

    return if File.directory?(full_path) || ["/", "."].include?(full_path)
    create_folders_for(full_path)
    Dir::mkdir(full_path)
  end

  def write_file full_path, file_content
    create_folders_for full_path
    File.open(full_path, 'w'){|f| f.write(file_content)}
  end

end