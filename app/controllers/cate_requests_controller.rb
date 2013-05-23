require 'cate'

class CateRequestsController < ApplicationController

  # POST to this action with credetials and cate path
  def portal
    cate = Cate.new params[:user], params[:pass]
    response = cate.get_page(params[:path])
    render :json => {:body => response.body}
  end

end
