# Copyright (C) 2025 Frank Mayer, Enes Korkmaz, Jascha Sonntag, Andreas Rothaler, Eray Akyazililar, Jan Magister
#
# This file is part of Elink.
#
# Elink is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Elink is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Elink. If not, see <http://www.gnu.org/licenses/>.

class RegistrationsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    @token = params[:token]
    if User.decode_registration_token(@token).nil?
      head :unauthorized and return
    end

    @user = User.find_by(registration_token: @token)

    if @user.nil?
      @user = User.new
    else
      # user already exists
      redirect_to login_path
    end
  end

  def create
    @token = params[:token]
    if User.decode_registration_token(@token).nil?
      head :unauthorized and return
    end

    @user = User.new(user_params)
    @user.registration_token = @token
    @user.role = "expert"

    if @user.save
      session[:user_id] = @user.id
      redirect_to new_expert_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
