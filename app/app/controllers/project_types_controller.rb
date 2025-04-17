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

class ProjectTypesController < ApplicationController
  before_action :set_project_type, only: %i[update]
  before_action :authorize_user

  def authorize_user
    unless current_user&.role.in?(%w[intern employee])
      flash[:alert] = I18n.t("flash.access_denied2")
      redirect_to expert_path(current_user.expert)
    end
  end

  def create
    @project_type = ProjectType.new(project_type_params)
    respond_to do |format|
      if @project_type.save
        # Respond with JSON for JavaScript requests
        format.json { render json: { id: @project_type.id, type_name: @project_type.type_name }, status: :created }
        # Respond with HTML for regular form submissions
        format.html { redirect_to request.referer, notice: "Project type was successfully created." }
      else
        format.json { render json: @project_type.errors, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @project_type.update(project_type_params)
        format.html { redirect_to @project_type, notice: "Project type was successfully updated." }
        format.json { render :show, status: :ok, location: @project_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project_type.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_project_type
      @project_type = ProjectType.find(params[:id])
    end

    def project_type_params
      params.require(:project_type).permit(:type_name)
    end
end
