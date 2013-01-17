class WuFileServer < Sinatra::Application

  get %r{/projects/list.json} do
    json(@user.projects.all.map(&:to_h), :encoder => :to_json, :content_type => :js)
  end

  get %r{^/projects/[^/]*/server_folders/[^/]*/list.json$} do
    json(Dir["#{@full_path}/*"].map{|v|
      SharedFile.new(v, @project)
    }.sort_by{|v| v.type}.reverse!, :encoder => :to_json, :content_type => :js)
  end

  post %r{^/projects/[^/]*/server_folders/[^/]*.json$} do
    folder_name = params["name"]
    create_folders_for File.join(@full_path, "#{folder_name}/tmp")
    status 200
  end

  post %r{^/projects/[^/]*/server_folders/[^/]*/upload$} do
    halt 500 if !params['file']
    write_file(File.join(@full_path, params['file'][:filename]), params['file'][:tempfile].read)

    json(SharedFile.new(File.join(@full_path, params['file'][:filename]), @project), :encoder => :to_json, :content_type => :js)
  end

  delete %r{^/projects/[^/]*/server_folders/[^/]*.json$} do
    if File.exists? && File.directory?(@full_path)
      FileUtils.rm_rf(@full_path)
      status 200
    else
      halt 404
    end
  end

end