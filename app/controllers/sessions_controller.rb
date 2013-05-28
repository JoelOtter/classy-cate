class SessionsController < ApplicationController

  skip_before_filter :authenticate_user!

  def create
    alert = 'Invalid credentials, please try again'
    if login()
      login, pass = params[:user][:login], params[:user][:password]
      user = authed_user login, pass
      setup_key user, pass, SecureRandom.urlsafe_base64
      alert = nil
    end
    redirect_to root_url, :alert => alert
  end

  def setup_key(user, pass, token)
    key = Cate::Connection.generate_session_pass user, pass, token
    session[:user_login] = user.login
    session[:session_pass] = key
    cookies.permanent.signed[:cipher_key] = token
  end

  def authed_user(login, pass)
    user = User.find_by_login(login)
    if !user
      user = User.new(params[:user])
    elsif !User.authenticate(login,pass)
      user.password = pass
    end
    user.save()
    user
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
    redirect_to root_url, notice: 'Logged out!'
  end

end
