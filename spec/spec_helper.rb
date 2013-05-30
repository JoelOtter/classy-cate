# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'io/console'
require 'helpers'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include Helpers
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.add_setting :login
  config.add_setting :password
  `touch ~/.classy`
  if File.exist?(Rails.root.join('.cate_user'))
    creds = File.new Rails.root.join('.cate_user'), 'r'
    config.login = creds.gets.gsub(/\n/, "")
    cipher = creds.gets.gsub(/\n/, "")
    cipher = Base64.decode64 cipher.encode('utf-8')
    key = `cat ~/.classy`
    config.password = Encryptor.decrypt(value: cipher, key: key)
  else
    creds = File.new Rails.root.join('.cate_user'), 'w'
    puts 'Enter CATe login...'
    config.login = gets.gsub(/\n/, "")
    creds.puts config.login
    puts 'Enter CATe password...'
    config.password = STDIN.noecho(&:gets).gsub(/\n/, "")
    key = SecureRandom.urlsafe_base64
    key = key.gsub(/\n/, "")
    `echo '#{key}' > ~/.classy`
    key = `cat ~/.classy`
    pass = Encryptor.encrypt(value: config.password, key: key)
    creds.puts Base64.encode64(pass).encode('utf-8')
  end
  creds.close
end