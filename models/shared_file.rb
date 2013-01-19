require 'base64'
require 'gibberish'

class SharedFile

  attr_reader :type, :name, :path, :key, :public_path

  def initialize file, project
    @type        = File.file?(file) ? "file" : "folder"
    @name        = File.basename(file)
    @project_key = project.key
    temp_path    = file.gsub(/^#{server_path}\/#{project.name}\//, "")
    @path        = (File.dirname(temp_path) == ".") ? "" : File.dirname(temp_path)
    @key         = Base64.strict_encode64(temp_path)
    if @type == "file"
      @last_update = File.mtime(file).utc
      @size        = File.size(file)
    end
    @public_path = SharedFile.encrypt_for_public(file) if @type == "file"
  end

  def self.encrypt_for_public path
    cipher = Gibberish::AES.new(public_secret_key)
    Base64.strict_encode64(cipher.enc(path))
  end

  def self.decrypt_for_public key
    cipher = Gibberish::AES.new(public_secret_key)
    cipher.dec(Base64.strict_decode64(key))
  end

end