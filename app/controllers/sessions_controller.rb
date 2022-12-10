# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate_user_using_x_auth_token

  def create
    @user = User.find_by!(email: login_params[:email].downcase)
    unless @user.authenticate(login_params[:password])
      respond_with_error(t("session.incorrect_credentials"), :unauthorized)
    end
  end
  # Note that, Rails, by convention, expects a view file for the create action in the views directory. If that can't be found, then Rails will point out that the relevant template file is missing.

  private

    def login_params
      params.require(:login).permit(:email, :password)
    end
end
