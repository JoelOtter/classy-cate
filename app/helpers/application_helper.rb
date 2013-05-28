# encoding: UTF-8
module ApplicationHelper

  def user_signed_in?
    User.find_by_login session[:user_login]
  end

  def current_user
    login = session[:user_login]
    @current_user ||= User.find_by_login(login) if session[:user_login]
  end

end
