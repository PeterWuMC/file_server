def server_path
  $server_path ||= YAML.load(File.read(File.join(Dir.pwd, "config/setup.yml")))["server_path"]
end

def db_settings
  $db_setting ||= YAML.load(File.read(File.join(Dir.pwd, "config/setup.yml")))["database"]
end

def secret_key
	$secret_key ||= YAML.load(File.read(File.join(Dir.pwd, "config/setup.yml")))["secret_key"]
end

def public_secret_key
	$public_secret_key ||= YAML.load(File.read(File.join(Dir.pwd, "config/setup.yml")))["public_secret_key"]
end