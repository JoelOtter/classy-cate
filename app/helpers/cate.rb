require 'net/https'
require 'net/http'
require 'uri'

class Cate

  def initialize(u)
    @user = u
    url = URI.parse('https://cate.doc.ic.ac.uk/')
    @http = Net::HTTP.new(url.host, url.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def get_page(path, pass)
    url = URI.parse('https://cate.doc.ic.ac.uk/' + path)
    request = Net::HTTP::Get.new(url.request_uri)
    request.basic_auth(@user, pass)
    response = @http.start {|http| http.request(request) }
    case response
    when Net::HTTPSuccess then
      response['location'] = path
      return response
    when Net::HTTPRedirection then
      puts 'Redirecting to'
      puts response['location']
      get_page response['location'], pass
    else
      return response
    end
  end

  def get_profile_pic(pass)
    get_page('/photo/student/pics12/' + @user + '.jpg', pass)
  end

  def verify_login(pass)
    response = get_page('/',pass)
    response.code != '401'
  end

  def destroy
    @user = ''
  end
  
end