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

class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
  end

  def create
    user = User.find_by(username: params[:username])


    if user&.authenticate(params[:password])
      session[:user_id] = user.id # Store user ID in session

      case user.role
      when "expert"
        if user.expert.nil?
          redirect_to new_expert_url, notice: I18n.t("login.welcome_expert", username: user.username)
        else
          redirect_to expert_path(user.expert), notice: I18n.t("login.welcome_expert", username: user.username)
        end

      when "employee", "intern"
        redirect_to root_path, notice: I18n.t("login.welcome_role", role: user.role)
      else
        redirect_to root_path, notice: I18n.t("login.welcome_role", role: user.role)
      end
    else
      flash[:alert] = I18n.t("login.invalid_credentials")

      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil # Clear session on logout
    flash[:notice] = I18n.t("login.logged_out")
    redirect_to login_path
  end
end
