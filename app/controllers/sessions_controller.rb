class SessionsController < ApplicationController

  skip_before_filter :authenticate_user!

  def create
    verified = login()
    puts '*** CREATING NEW SESSION ***'
    user = User.authenticate(params[:user][:login], params[:user][:password])
    # correct credentials
    if login()
      if !user
        user = User.new(params[:user])
        user.save()
      end
      # set the current session user
      session[:user_login] = user.login
      # generate random token for key
      random_token = SecureRandom.urlsafe_base64
      # push into the cookie the random token that is
      # about to expire
      cookies.permanent.signed[:cipher_key] = random_token
      password = params[:user][:password]
      key = Cate::Connection.generate_session_pass user, password, random_token
      session[:session_pass] = key
      redirect_to root_url
    else
      redirect_to root_url, :alert => 'Invalid credentials, please try again'
    end
  end

  def login
    params[:user][:login] = params[:user][:email].split('@')[0]
    cate = Cate::Connection.new params[:user][:login]
    verified = cate.verify_login(params[:user][:password])
    cate.destroy()
    return verified
  end

  def logout
    session[:user_login] = nil
    redirect_to root_url, :notice => 'Logged out!'
  end

end
