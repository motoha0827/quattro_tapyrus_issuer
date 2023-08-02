# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :signed_in?, only: %i[show]

  def show
    @user = current_user
  end

  def new; end

  def create
    user = User.new(user_params)
  end

  private

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :phone_number, :email)
  end
end