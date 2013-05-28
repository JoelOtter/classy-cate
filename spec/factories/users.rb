# spec/factories/user.rb
require 'faker'

FactoryGirl.define do
  factory :user do |f|
    f.login { Faker::Internet.user_name }
    f.password 'password'
  end
end
