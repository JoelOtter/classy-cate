require 'cate'

class Devise::SessionsController < DeviseController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  prepend_before_filter :allow_params_authentication!, :only => :create
  prepend_before_filter { request.env["devise.skip_timeout"] = true }

  # GET /resource/sign_in
  def new
    puts 'new'
    if @go
      login()
    else
      self.resource = build_resource(nil, :unsafe => true)
      clean_up_passwords(resource)
      respond_with(resource, serialize_options(resource))
      @go = true
    end
  end

  def login
    @go = false
    puts 'logging in...'
    params[:user][:login] = params[:user][:email].split('@')[0]
    params[:user][:password_confirmation] = params[:user][:password]
    @cate = Cate.new(params[:user][:login], params[:user][:password])
    if @cate.verify_login()
      puts 'cate verifies login'
      user = User.find_by_email(params[:user][:email])
      if !user.blank?
        if user.valid_password?(params[:user][:password])
          new()
        end
      else
        create()
      end
    else
      new()
    end
    @cate.destroy()
  end

  # POST /resource/sign_in
  def create
    if @go
      login()
    else
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with(resource, serialize_options(resource))
      @go = true
    end
  end

  # DELETE /resource/sign_out
  def destroy
    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_navigational_format?

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to redirect_path }
    end
  end

  protected

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { :methods => methods, :only => [:password] }
  end

  def auth_options
    { :scope => resource_name, :recall => "#{controller_path}#new" }
  end

end
