module Helpers
  def authorise(user, pass)
    random = SecureRandom.urlsafe_base64
    Cate::Connection.generate_session_pass user, pass, random
    session[:user_login] = user.login
    cookies.permanent.signed[:cipher_key] = random
  end
end