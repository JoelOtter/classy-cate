require 'cate'
require 'openssl'

class CateRequestsController < ApplicationController

  # POST to this action with credetials and cate path
  def portal
    puts 'HITTING UP CATE!'
    # create a new cate instance and use to access data
    cate = Cate.new current_user.login
    # save response
    response = cate.get_page(params[:path], get_pass())
    puts response['location']
    # invalidate cate instance
    cate.destroy()
    # render the result
    render :json => {:content => response.body, :path => response['location']}
  end

  def profile_pic
    puts 'GETTING PROFILE PIC'
    cate = Cate.new current_user.login
    response = cate.get_profile_pic(get_pass())
    cate.destroy()
    send_data response.body, :type => 'image/jpg'
  end

  def get_pass
    puts 'ACCESSING USER PASS'
    # get the current encoded password
    encoded = current_user.session_pass
    # decode that result from utf-8
    cipher = Base64.decode64 encoded.encode('utf-8')
    # retrive the standard key from cookie
    cookie_key = cookies.signed[:cipher_key]
    # generate decryption key using sha256
    key = Digest::SHA256.hexdigest cookie_key
    # decrypt and return the password
    Encryptor.decrypt(:value => cipher, :key => key)
  end

end
