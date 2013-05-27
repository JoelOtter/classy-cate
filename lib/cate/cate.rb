require 'net/https'
require 'net/http'
require 'uri'

module Cate
  class Connection

    def initialize(u)
      @user = u
      url = URI.parse('https://cate.doc.ic.ac.uk/')
      @http = Net::HTTP.new(url.host, url.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def self.generate_session_pass(user, pass, digest)
      puts 'MAKING CIPHER'
      # generate a key from the old session id
      key = Digest::SHA256.hexdigest(digest)
      # encrypt the password with the digest key
      cipher = Encryptor.encrypt(:value => pass, :key => key)
      # encode the cipher for db storage
      encoded = Base64.encode64(cipher).encode('utf-8')
      # save the scrambled pass into the database
      user.update_attribute('session_pass', encoded)
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
end