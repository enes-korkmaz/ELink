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

class ExpertsController < ApplicationController
  before_action :set_expert, only: %i[ show edit update destroy ]

  add_breadcrumb I18n.t("nav_bar.experts"), :experts_path, unless: -> { current_user.role == "expert" }

  # GET /experts or /experts.json
  def index
    if !authorize_user
      return
    end
    @experts = Expert.all

    @recently_updated = Expert.where("updated_at >= ?", 1.week.ago).order(updated_at: :desc).limit(10)
    @recently_registered = Expert.where("created_at >= ?", 1.week.ago).order(created_at: :desc).limit(10)
  end

  def authorize_user
    unless current_user&.role.in?(%w[intern employee])
      flash[:alert] = I18n.t("flash.access_denied2")
      redirect_to expert_path(current_user.expert)
      return false
    end
    true
  end

  def authorize_user_allow_empty_expert
    return true if current_user&.role.in?(%w[intern employee])

    return true if current_user&.role == "expert" && current_user.expert.nil?

    flash[:alert] = I18n.t("flash.access_denied2")
    redirect_to expert_path(current_user.expert)
    false
  end

  def authorize_user_allow_own_expert
    return true if current_user&.role.in?(%w[intern employee])

    return true if current_user&.role == "expert" && current_user.expert.id == @expert.id

    flash[:alert] = I18n.t("flash.access_denied2")
    redirect_to expert_path(current_user.expert)
    false
  end

  # GET /experts/1 or /experts/1.json
  def show
    add_breadcrumb "#{@expert.title} #{@expert.last_name}, #{@expert.first_name}", :expert_path
    authorize_user_allow_own_expert
  end

  # GET /experts/new
  def new
    if !authorize_user_allow_empty_expert
      return
    end
    @expert = Expert.new
    if current_user&.role == "expert"
      @expert.email = current_user.username
    end
    add_breadcrumb I18n.t("homepage.create_new_expert")
  end

  # GET /experts/1/edit
  def edit
    authorize_user_allow_own_expert
    add_breadcrumb "#{@expert.title} #{@expert.last_name}, #{@expert.first_name}", :expert_path
    add_breadcrumb I18n.t("actions.edit")
  end

  # POST /experts or /experts.json
  def create
    if !authorize_user_allow_empty_expert
      return
    end
    @expert = Expert.new(expert_params)
    if current_user.role == "expert"
      @expert[:user_id] = current_user.id
    end

    respond_to do |format|
      if @expert.save
        format.html { redirect_to @expert, notice: I18n.t("flash.expert_created") }
        format.json { render :show, status: :created, location: @expert }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @expert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /experts/1 or /experts/1.json
  def update
    if !authorize_user_allow_own_expert
      return
    end
    @del_doc = false
    @duplicate_certificates = false
    @update_params = expert_params

    # Remove document removal flags from params before checking for parameter changes
    filtered_params = @update_params.except(:remove_profile_picture, :remove_resume, :remove_certificates)

    if document_removal_requested
      @del_doc = true
    end

    @duplicate_certificates = true if duplicate_files_detected?

    if check_for_param_changes(filtered_params)
      respond_to do |format|
        if @del_doc
          if @expert.update(filtered_params)
            handleDuplicateCertificates() if @duplicate_certificates
            remove_document(filtered_params)
            flash[:notices] = [ flash[:notices], t("flash.expert_updated") ].compact.join(" ")
            format.html { render :edit, notice: flash[:notices] }
            format.json { render :show, status: :ok, location: @expert }
          else
            flash[:alerts] = [ flash[:alert], t("notices.expert_update_failed") ].compact.join(" ")
            format.html { render :edit, status: :unprocessable_entity }
            format.json { render json: @expert.errors, status: :unprocessable_entity }
          end
        else
          if @expert.update(filtered_params)
            handleDuplicateCertificates() if @duplicate_certificates
            format.html { redirect_to @expert, notice: t("flash.expert_updated") }
            format.json { render :show, status: :ok, location: @expert }
          else
            flash[:alert] = t("notices.expert_update_failed")
            format.html { render :edit, status: :unprocessable_entity }
            format.json { render json: @expert.errors, status: :unprocessable_entity }
          end
        end
      end
    else
      if @del_doc
        # If only deleting doc(s)
        remove_document(filtered_params)
      end
    end
  end

  # DELETE /experts/1 or /experts/1.json
  def destroy
    if !authorize_user
      return
    end
    @expert.destroy!
    # handle redirect when user role expert destroys
    respond_to do |format|
      format.html { redirect_to experts_path, status: :see_other, notice: I18n.t("flash.expert_destroyed") }
      format.json { head :no_content }
    end
  end

  def remove_document(filtered_params)
    %i[profile_picture resume].each do |document_name|
      if params[:expert]["remove_#{document_name}"] == "true"
        document = @expert.send(document_name)
        if document.attached?
          document.purge_later
          message = t("notices.delete_success", document: t("activerecord.attributes.expert.documents.#{document_name}"))
          # Append message if there are other changes, otherwise just show the success message
          flash[:notices] = if filtered_params.present?
                            [ flash[:notice], message ]
          else
                           message
          end
        else
          message = t("notices.delete_failed", document: t("activerecord.attributes.expert.documents.#{document_name}"))
          # Append message if there are other changes, otherwise just show the failure message
          flash[:alerts] = if filtered_params.present?
                          [ flash[:alert], message ]
          else
                          message
          end
        end
      end
    end
  end

  # Method to handle duplicate certificates deletion and attaching the new ones
  def handleDuplicateCertificates
    if params[:expert][:certificates].present?
      params[:expert][:certificates].each do |new_file|
        next unless new_file.is_a?(ActionDispatch::Http::UploadedFile)

        # Find existing files with the same name and remove them
        existing_files = @expert.certificates.select do |certificate|
          certificate.filename.to_s == new_file.original_filename
        end

        # Detach old files
        existing_files.each(&:purge)

        # Attach the new file after purging the old one
        @expert.certificates.attach(new_file)
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expert
      @expert = Expert.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def expert_params
      params.require(:expert).permit(:salutation, :title, :first_name, :last_name,
                                    :nationality, :phone_number, :email,
                                    :current_location, :language_id,
                                    :hourly_rate, :daily_rate,
                                    :travel_willingness_online, :travel_willingness_germany,
                                    :travel_willingness_china, :travel_willingness_text,
                                    :spontaneous, :has_china_reference, :china_reference,
                                    :extra_skills, :has_institution, :institution_name,
                                    :cooperation_options, :free_text, :profile_picture,
                                    :resume, certificates: [], language_ids: [], category_ids: [])
    end

    def check_for_param_changes(filtered_params)
      filtered_params.to_h.any? do |key, value|
        # Check if the value in the project is different
        @expert.read_attribute(key.to_s) != value
      end
    end

    def document_removal_requested
      %w[profile_picture resume].any? do |doc_name|
        params[:expert]["remove_#{doc_name}"] == "true"
    end

    def duplicate_files_detected?
      return false unless params[:expert][:certificates].present?

      params[:expert][:certificates].each do |new_file|
        next unless new_file.is_a?(ActionDispatch::Http::UploadedFile)

        # Check for existing certificates with the same name
        existing_certificates = @expert.certificates.select do |certificate|
          certificate.filename.to_s == new_file.original_filename
        end

        # Return true if there are any existing certificates with the same filename
        return existing_certificates.any?
      end

      false # Ensure that false is returned if no duplicate is found
    end
  end
end
