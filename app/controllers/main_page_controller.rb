class MainPageController < ApplicationController

  def index
    if user_signed_in?
      Dashboard.index
    else
      render
    end
  end

end
