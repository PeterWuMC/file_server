class SharedFile

  attr_reader :type, :name, :path, :key

  def initialize file
    @type        = File.file?(file) ? "file" : "folder"
    @name        = File.basename(file)
    temp_path    = file.gsub(/^#{server_path}\//, "")
    @path        = (File.dirname(temp_path) == ".") ? "" : File.dirname(temp_path)
    @key         = Base64.strict_encode64(temp_path)
    if @type == "file"
      @last_update = File.mtime(file).utc
      @size        = File.size(file)
    end
  end

end