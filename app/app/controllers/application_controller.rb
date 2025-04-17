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

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :require_login
  before_action :set_locale

  helper_method :current_user # Make current_user accessible in views

  private

  # Check if user is logged in
  def require_login
    unless current_user
      flash[:alert] = I18n.t("flash.login_required")
      redirect_to login_path
    end
  end

  # Method to make current_user accessible in views and controllers
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def authorize(role)
    unless current_user&.role == role
      flash[:alert] = I18n.t("flash.access_denied")
      redirect_to root_path
    end
  end

  def set_locale
    I18n.locale = get_locale
  end

  def get_locale
    return I18n.default_locale unless request.headers.key?("HTTP_ACCEPT_LANGUAGE")

    string = request.headers.fetch("HTTP_ACCEPT_LANGUAGE")&.scan(/^[a-z]{2}/)&.first

    return I18n.default_locale unless I18n.available_locales.map(&:to_s).include?(string)

    string
  end
end
