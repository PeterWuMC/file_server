require 'yaml'
helpers do

  def server_path
    $server_path ||= YAML.load(File.read(File.join(Dir.pwd, "config/setup.yml")))["server_path"]
  end

  def check_and_return_path key
  	path      = Base64.strict_decode64(key)
    full_path = File.join(server_path, path)
    raise Sinatra::NotFound if !(full_path && File.exist?(full_path))
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
