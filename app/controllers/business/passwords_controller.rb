# frozen_string_literal: true

class Business::PasswordsController < ApplicationController
  before_action :require_business!

  def show
    @user = current_user
  end

  def update
    @user = current_user
    sign_in @user, bypass: true if (@saved = @user.update_with_password(password_params))
    render :show
  end

  private

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
