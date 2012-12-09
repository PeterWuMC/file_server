require 'yaml'
helpers do

  def server_path
    @@server_path ||= YAML.load(File.read(File.join(Dir.pwd, "config/setup.yml")))["server_path"]
  end

  def decode_key key
    Base64.strict_decode64 key
  rescue
    raise Sinatra::NotFound
  end

end
