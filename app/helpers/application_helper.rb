module ApplicationHelper

  def user_signed_in?
    User.find_by_login session[:user_login]
  end

  def current_user
    @current_user ||= User.find_by_login(session[:user_login]) if session[:user_login]
  end

end
