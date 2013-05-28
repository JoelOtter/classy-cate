require 'spec_helper'

describe 'main_page/index' do

  context 'user is authenticated' do
    before(:each) do
      FactoryGirl.create(:user, login: 'tom112', password: 'password')
      session[:user_login] = 'tom112'
    end
    it 'does not render login form' do
      render
      expect(view).to_not render_template(partial: '_login_form')
    end
    it 'renders navbar' do
      render template: 'layouts/application'
      expect(view).to render_template(partial: '_navbar')
    end
    it 'renders footer' do
      render template: 'layouts/application'
      expect(view).to render_template(partial: '_footer')
    end

  end

  context 'user is not authenticated' do
    it 'renders login form' do
      render
      expect(view).to render_template(partial: '_login_form')
    end
    it 'does not render navbar' do
      render template: 'layouts/application'
      expect(view).to_not render_template(partial: '_navbar')
    end
    it 'does not render footer' do
      render template: 'layouts/application'
      expect(view).to_not render_template(partial: '_footer')
    end
  end

end