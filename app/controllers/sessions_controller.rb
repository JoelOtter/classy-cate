class SessionsController < ApplicationController

  skip_before_filter :authenticate_user!

  def create
    # correct credentials
    if login()
      login, pass = params[:user][:login], params[:user][:password]
      user = User.authenticate(login,pass)
      if !user
        user = User.new(params[:user])
        user.save()
      end
      # generate random token for key
      token = SecureRandom.urlsafe_base64
      # push into the cookie the random token that is
      # about to expire
      cookies.permanent.signed[:cipher_key] = token
      key = Cate::Connection.generate_session_pass user, pass, token
      session[:user_login], session[:session_pass] = login, key
      redirect_to root_url
    else
      redirect_to root_url, :alert => 'Invalid credentials, please try again'
    end
  end

  def login
    params[:user][:email] = params[:user][:login] + '@ic.ac.uk'
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
