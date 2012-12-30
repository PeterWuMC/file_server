def server_path
  $server_path ||= YAML.load(File.read(File.join(Dir.pwd, "config/setup.yml")))["server_path"]
end

def db_settings
  $db_setting ||= YAML.load(File.read(File.join(Dir.pwd, "config/setup.yml")))["database"]
end