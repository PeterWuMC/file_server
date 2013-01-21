class WuFileServer < Sinatra::Application

  post '/registration' do
    device      = nil
    password    = params["password"]
    device_name = params["device_name"]
    device_id   = params["device_id"]

    if @user_name && password && device_id
      user   = User.find_by_user_name(@user_name).try(:authenticate, password)
      unrecognized_credential unless user
      device = user.find_or_create_device device_id, device_name
    else
      incomplete_data_provided
    end
    status 202 # ACCEPTED
    json({device_code: device.device_code}, :encoder => :to_json, :content_type => :js)
  end

  post %r{^/registration/check$} do
    device      = nil
    device_code = params["device_code"]

    user = User.find_by_user_name(@user_name)
    unrecognized_credential if !user || !user.devices.find_by_device_code(device_code)

    status 200
  end

end