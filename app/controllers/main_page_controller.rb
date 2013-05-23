class MainPageController < ApplicationController

  skip_before_filter :authenticate_user!

  def index
    if user_signed_in?
      redirect_to '/dashboard'
    else
      render
    end
  end

end
