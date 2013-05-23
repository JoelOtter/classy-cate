require 'net/https'
require 'net/http'
require 'uri'

class Cate

  def initialize(u, p)
    @user = u 
    @pass = p
  end

  def get_page(path)
    url = URI.parse('https://cate.doc.ic.ac.uk/' + path)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url.request_uri)
    request.basic_auth(@user, @pass)
    return http.start {|http| http.request(request) }
  end

  def verify_login
    response = get_page '/'
    response.code != '401'
  end

  def destroy
    @user = ''
    @pass = ''
  end
  
end