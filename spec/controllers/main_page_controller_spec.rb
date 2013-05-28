require 'spec_helper'

describe MainPageController do

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template 'index'
    end
    it 'responds successfully with status 200' do
      get :index
      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

end