class WuFileServer < Sinatra::Application

  #.delete(:key)
    delete %r{^/projects/[^/]*/server_files/[^/]*.json$} do
      if File.exists?(@full_path) && File.file?(@full_path)
        File.delete(@full_path)
        status 200
      else
        halt 404
      end
    end

    get %r{^/projects/[^/]*/server_files/[^/]*/download$} do
      send_file(@full_path, :disposition => 'attachment', :filename => File.basename(@full_path))
      status 200
    end

    get %r{^/projects/[^/]*/server_files/[^/]*/thumbnail$} do
      # send_file(@full_path, :disposition => 'attachment', :filename => File.basename(@full_path))
      halt 404 if !(["jpg", "png"].include?(File.extname(@full_path).downcase[1..-1]))

      content_type 'application/octet-stream'
      image = Magick::Image.read(@full_path).first
      # image.thumbnail(i.columns*0.06, i.rows*0.06).write("#{file}-thumb.jpg")
      attachment('test.jpg')
      response.write(image.resize_to_fit(100,100).to_blob)
      # status 200
    end


    # # .find(:all)
    # get %r{/project/(.*)/server_files.json} do |project_key|
    #   json(Dir["#{server_path}/**/*"].select{|v| File.file?(v)}.map{|v|
    #     SharedFile.new(v)
    #   }, :encoder => :to_json, :content_type => :js)
    # end

    # # .find(:key).get(:download)
    # get %r{^/server_files/(.*)/download\.json$} do |key|
    #   full_path, path = check_and_return_path(key)

    #   file = nil
    #   File.open(full_path, 'rb'){|f| file = f.read}

    # # TODO
    #   json({key: key, path: path, file_content: Base64.encode64(file)}, :encoder => :to_json, :content_type => :js)
    # end

    # #.find(:key)
    # get %r{^/server_files/(.*)\.json$} do |key|
    #   full_path, path = check_and_return_path(key)

    #   json(SharedFile.new(full_path), :encoder => :to_json, :content_type => :js)
    # end

    # #.find(:key).update_attributes(:xxxx, yyyy)
    # put %r{^/server_files/(.*)\.json$} do |key|
    #   full_path, path = check_and_return_path(key)

    #   server_file  = JSON.parse(request.body.read)["server_file"]

    #   path         = server_file["path"]
    #   file_content = Base64.decode64(server_file["file_content"])
    #   write_file(full_path, file_content)

    #   status 200
    # end

    # #.new(:xxx => yyy)
    # post '/server_files.json' do
    #   server_file  = JSON.parse(request.body.read)["server_file"]

    #   path         = server_file["path"]
    #   full_path    = File.join(server_path, path)
    #   file_content = Base64.decode64(server_file["file_content"])
    #   write_file(full_path, file_content)

    #   status 200
    # end

  end