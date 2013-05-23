class MainPageController < ApplicationController

  skip_before_filter :authenticate_user!

  def index
    puts session
  end

end
