require 'bcrypt'

class User < ActiveRecord::Base
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :login, :password, :session_pass

  attr_accessor :password
  before_save :encrypt_password

  validates_presence_of :password, :on => :create
  validates_presence_of :login
  validates_uniqueness_of :login
  validates_uniqueness_of :email


  def self.authenticate(login, password)
    user = find_by_login login
    if user
      if user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
        return user
      end
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

end
