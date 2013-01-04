class SharedFile

  def initialize file
    @file        = file
    @type        = File.file?(file) ? "file" : "folder"
      @name        = File.basename(file)
      @path        = file.gsub(/^#{server_path}\//, "")
      @key         = Base64.strict_encode64(@path)
    if @type == "file"
      @last_update = File.mtime(file).utc
      @size        = File.size(file)
    end
  end

end