require 'sinatra'
require 'json'

get '/list' do 
  content_type :json  
  Dir["/media/ukserver/**/*"].select{|v| File.file?(v)}.map{|v| v.gsub(/^\/media\/ukserver/, "")}.to_json
end

put '/single-file' do
  if params[:file]
    file = File.join("/media/ukserver", params[:file])
    if file && File.exist?(file)
      send_file(file)
    end
  end
  nil
end

