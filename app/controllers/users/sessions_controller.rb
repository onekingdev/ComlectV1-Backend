# frozen_string_literal: true
class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  respond_to :js, :html

  # POST /resource/sign_in
  def create
    respond_to do |format|
      format.html { super }
      format.js do
        if (self.resource = warden.authenticate(auth_options))
          set_flash_message!(:notice, :signed_in)
          sign_in(resource_name, resource)
        else
          flash.now[:warning] = 'Invalid email or password'
        end
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    respond_to do |format|
      format.html { super }
      format.js do
        signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        set_flash_message! :notice, :signed_out if signed_out
      end
    end
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.business
      business_dashboard_path
    else
      super
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
