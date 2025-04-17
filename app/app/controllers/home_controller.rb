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

class HomeController < ApplicationController
  before_action :authorize_user

  def overview
    add_breadcrumb I18n.t("nav_bar.homepage")
    @recently_invoked = Project.where("updated_at > ?", 7.days.ago).order(updated_at: :desc).limit(10)
    @recently_added = Project.order(created_at: :desc).limit(10)
    @in_planing = Project.where(project_status: :planning).order(project_date_from: :asc)
    @recently_finished = Project.where(project_status: :completed)
                             .where("updated_at >= ? OR created_at >= ?", 1.week.ago, 1.week.ago)
                             .order(updated_at: :desc)
                             .limit(10)

    @recently_updated = Expert.where("updated_at >= ?", 1.week.ago).order(updated_at: :desc).limit(10)
    @recently_registered = Expert.where("created_at >= ?", 1.week.ago).order(created_at: :desc).limit(10)
  end

  private

  def authorize_user
    unless current_user&.role.in?(%w[intern employee])
      flash[:alert] = I18n.t("flash.access_denied2")
      redirect_to expert_path(current_user.expert)
    end
  end
end
