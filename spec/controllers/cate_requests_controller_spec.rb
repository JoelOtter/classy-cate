require 'spec_helper'

describe CateRequestsController do

  describe 'POST #portal' do
    context 'not authenticated' do
      it 'bars the user' do
        post :portal
        expect(response).to redirect_to root_url
        flash[:alert].should =~ /Please enter your login/i
      end
    end

    context 'authenticated' do
      before(:each) do
        l, p = RSpec.configuration.login, RSpec.configuration.password
        user = FactoryGirl.create(:user, login: l, password: p)
        authorise(user, p)
      end
      context 'expired session pass' do
        before(:each) do
          cookies.permanent.signed[:cipher_key] = 
            SecureRandom.urlsafe_base64
        end
        it 'bars my user' do
          post :portal, path: '/', format: :json
          response.should be_success
          content = JSON.parse response.body
          content['code'].should eq('401')
        end
      end
      context 'correct session pass' do
        it 'returns cate data' do
          post :portal, path: '/', format: :json
          response.should be_success
          content = JSON.parse response.body
          content['code'].should eq('200')
        end
      end
    end
  end

end