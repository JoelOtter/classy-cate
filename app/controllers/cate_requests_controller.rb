# encoding: UTF-8
class CateRequestsController < ApplicationController

  # POST to this action with credetials and cate path
  def portal
    current_user.login
    # create a new cate instance and use to access data
    cate = Cate::Connection.new current_user.login
    # save response
    response = cate.get_page(params[:path], get_pass())
    # invalidate cate instance
    cate.destroy()
    # render the result
    render json: {
      content: response.body,
      path: response['location'],
      code: response.code
    }
  rescue
    bar_user()
  end

  def profile_pic
    cate = Cate::Connection.new current_user.login
    response = cate.get_profile_pic(get_pass())
    cate.destroy()
    send_data response.body, type: 'image/jpg'
  rescue
    bar_user()
  end

  def download
    cate = Cate::Connection.new current_user.login
    response = cate.get_page(params[:path], get_pass())
    puts response['content_disposition']
    cate.destroy()
    send_data response.body, type: response.content_type
  rescue
    bar_user()
  end

  def bar_user
    session[:user_login] = nil
    flash[:alert] = 'You have been signed in on another computer'
    render json: { status: 'UserDenied', redirect: '/', code: '401' }
  end

  def get_pass
    # get the current encoded password
    encoded = current_user.session_pass
    # decode that result from utf-8
    cipher = Base64.decode64 encoded.encode('utf-8')
    # retrive the standard key from cookie
    cookie_key = cookies.signed[:cipher_key]
    # generate decryption key using sha256
    key = Digest::SHA256.hexdigest cookie_key
    # decrypt and return the password
    Encryptor.decrypt(value: cipher, key: key)
  rescue
    raise 'UserDenied'
  end

end
