require 'cate'
require 'openssl'

class CateRequestsController < ApplicationController

  # POST to this action with credetials and cate path
  def portal
    puts 'HITTING UP CATE ;)'
    get_pass params[:user], session[:session_id]
    cate = Cate.new params[:user], params[:pass]
    response = cate.get_page(params[:path])
    render :json => {:body => response.body}
  end

  def get_pass(login, session_id)
    aes = OpenSSL::Cipher::Cipher.new 'AES-256-CBC'
    aes.decrypt
    aes.key = session_id
    base = User.find_by_login(login).session_pass
    base = aes.update(base) + aes.final
    plaintext = Base64.decode64 base.encode('utf-8')
    puts plaintext
  end

end
