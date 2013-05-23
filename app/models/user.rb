class User < ActiveRecord::Base
  has_secure_password
  attr_accessible :login, :password_digest
  validates_presence_of :password, :on => :create
  validates_presence_of :login, :on => :create
end
