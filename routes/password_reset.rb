class WuFileServer < Sinatra::Application
  get '/password_reset' do
    haml :password_reset
  end

  post '/password_reset' do
    user_name            = params["user_name"]
    old_password         = params["old_password"]
    new_password         = params["new_password"]
    confirm_new_password = params["confirm_new_password"]

    user = User.find_by_user_name(user_name).try(:authenticate, old_password)

    if user
      user.password              = new_password
      user.password_confirmation = confirm_new_password
      if user.valid?
        user.save
        "Password Reset Completed!"
      else
        user.errors.full_messages
      end
    else
      "User name / password combination not found"
    end
  end
end