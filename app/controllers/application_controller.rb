class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!

  def authenticate_user!
    user = User.find_by_login session[:user_login]
    if user.nil?
      puts 'AUTH FAILED'
      redirect_to '/', :alert => 'Please enter your login'
    end
  end

  include ApplicationHelper

end
