# encoding: UTF-8
class MainPageController < ApplicationController

  skip_before_filter :authenticate_user!

  def index
  end

end
