require 'yaml'
helpers do

  def server_path
    @@server_path ||= YAML.load(File.read(File.join(Dir.pwd, "config/setup.yml")))["server_path"]
  end

end
