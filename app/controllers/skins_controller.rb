class SkinsController < ApplicationController
  def index
  end

  def dashboard
    render :partial => 'dashboard/index'
  end
  
end
