# spec/models/user.rb
require 'spec_helper'

describe User do

  it 'has a valid factory' do
    FactoryGirl.create(:user).should be_valid
  end

  it 'is invalid without a login' do
    FactoryGirl.build(:user, login: nil).should_not be_valid
  end

  context 'user is tom112, pass is password' do
    before :each do
      FactoryGirl.create(:user, login: 'tom112', password: 'password')
    end

    context 'authorise access' do
      it 'authenticates correct user credentials' do
        User.authenticate('tom112', 'password').should_not be_nil
      end
    end

    context 'deny access' do
      it 'denies access for incorrect user password' do
        User.authenticate('tom112', 'drowssap').should be_nil
      end
      it 'denies access for nonexistant user' do
        User.authenticate('dan', 'password').should be_nil
      end
    end

  end
end