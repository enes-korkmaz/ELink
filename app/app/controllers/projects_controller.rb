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

class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy remove_document
                                      add_partner remove_partner_document
                                      add_accommodation remove_accommodation_document
                                      add_catering remove_catering_document
                                      add_transport remove_transport_document
                                      delete_partner save_partner add_experts]
  before_action :authorize_user
  add_breadcrumb I18n.t("nav_bar.projects"), :projects_path

  # GET /projects or /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1 or /projects/1.json
  def show
    @project = Project.find(params[:id])
    add_breadcrumb @project.project_name, :project_path
    @active_tab = params[:tab] || "details" # Default to 'details' if no tab is specified
  end


  # GET /projects/new
  def new
    @project = Project.new
    add_breadcrumb I18n.t("homepage.create_new_project")
  end

  # GET /projects/1/edit
  def edit
    add_breadcrumb @project.project_name, :project_path
    add_breadcrumb I18n.t("actions.edit")
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)
    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: t("notices.project_created_success") }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    @del_doc = false
    @update_params = project_params

    # Remove document removal flags from params before checking for parameter changes
    filtered_params = @update_params.except(:remove_participant_list, :remove_invitation_document, :remove_certificate_document)

    @del_doc = true if document_removal_requested?

    # Check if there are any changes in the filtered parameters (excluding document removal flags)
    if check_for_param_changes(filtered_params)
      respond_to do |format|
        if @del_doc
          if @project.update(filtered_params)
            remove_document(filtered_params)
            flash[:notices] = [ flash[:notices], t("notices.update_success") ].compact.join(" ")
            format.html { render :edit, notice: flash[:notices] }
            format.json { render :show, status: :ok, location: @project }
          else
            flash[:alerts] = [ flash[:alert], t("notices.update_failed") ].compact.join(" ")
            format.html { render :edit, status: :unprocessable_entity }
            format.json { render json: @project.errors, status: :unprocessable_entity }
          end
        else
          if @project.update(filtered_params)
            format.html { redirect_to @project, notice: t("notices.update_success") }
            format.json { render :show, status: :ok, location: @project }
          else
            flash[:alert] = t("notices.update_failed")
            format.html { render :edit, status: :unprocessable_entity }
            format.json { render json: @project.errors, status: :unprocessable_entity }
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

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy!

    respond_to do |format|
      format.html { redirect_to projects_path, status: :see_other, notice: I18n.t("notices.project_destroy") }
      format.json { head :no_content }
    end
  end

  def authorize_user
    unless current_user&.role.in?(%w[intern employee])
      flash[:alert] = I18n.t("flash.access_denied2")
      redirect_to expert_path(current_user.expert)
    end
  end

  def remove_document(filtered_params)
    %i[participant_list invitation_document certificate_document].each do |document_name|
      if params[:project]["remove_#{document_name}"] == "true"
        document = @project.send(document_name)
        if document.attached?
          document.purge_later
          message = t("notices.delete_success", document: t("activerecord.attributes.project.documents.#{document_name}"))
          # Append message if there are other changes, otherwise just show the success message
          flash[:notices] = if filtered_params.present?
                           [ flash[:notice], message ].compact.join(" ")
          else
                           message
          end
        else
            message = t("notices.delete_failed", document: t("activerecord.attributes.project.documents.#{document_name}"))
            # Append message if there are other changes, otherwise just show the failure message
            flash[:alerts] = if filtered_params.present?
                            [ flash[:alert], message ].compact.join(" ")
            else
                            message
            end
        end
      end
    end
  end

  # Add Partner Form
  def add_partner
    @partner = @project.partners.build
    render partial: "projects/form_partner", locals: { partner: @partner }
  end

  # POST or PATCH /projects/1/partners
  def save_partner
    @project = Project.find_by(id: params[:id])
    @partner_params = partner_params

    if params[:partner_id].present?
      # Find the existing partner to update
      @partner = @project.partners.find_by(id: params[:partner_id])
      if @partner.update(@partner_params)
        flash[:notice] = "Partner updated successfully!"
      else
        flash[:alert] = "Failed to update partner."
      end
    else
      # Create a new partner
      @partner = @project.partners.build(@partner_params)
      if @partner.save
        flash[:notice] = "Partner added successfully!"
      else
        flash[:alert] = "Failed to add partner."
        logger.debug "Errors: #{@partner.errors.full_messages}" # Log any validation errors
      end
    end

    respond_to do |format|
      if @partner.errors.empty?
        format.json do
          render json: {
            status: "success",
            redirect_url: project_path(@project, tab: "partners") # Redirect URL after save
          }
        end
      else
        # Determine which form to re-render based on the presence of partner_id
        form_partial = params[:partner_id].present? ? "projects/edit_partner_form" : "projects/form_partner"

        format.js do
          render partial: form_partial,
                 status: :unprocessable_entity,
                 locals: { partner: @partner }
        end

        format.json { render json: @partner.errors, status: :unprocessable_entity }
      end
    end
  end


  def edit_partner
    @project = Project.find(params[:id])
    @partner = @project.partners.find(params[:partner_id])
    render partial: "edit_partner_form", locals: { partner: @partner }
  end

  def delete_partner
    @project = Project.find(params[:id])
    @partner = @project.partners.find(params[:partner_id])

    if @partner.destroy
      flash[:notice] = "Partner deleted successfully!"
      render json: { status: "success", message: "Partner deleted successfully!", redirect_url: project_path(@project, tab: "partners") }, status: :ok
    else
      flash[:alert] = "Failed to delete partner."
      render json: { status: "error", message: "Failed to delete partner" }, status: :unprocessable_entity
    end
  end

  def remove_partner_document
    @project = Project.find(params[:id])
    @partner = @project.partners.find(params[:partner_id])

    document_type = params[:document_type]

    if %w[invoice_document quotation_document].include?(document_type)
      @partner.update(document_type => nil)
      flash[:notice] = t("notices.delete_success", document: t("activerecord.attributes.tab_docs.#{document_type}"))
    else
      flash[:alert] = t("notices.delete_failed", document: t("activerecord.attributes.tab_docs.#{document_type}"))
    end

    redirect_to project_path(@project, tab: "partners")
  end

  # Add Accommodation Form
  def add_accommodation
    @accommodation = @project.accommodations.build
    render partial: "projects/form_accommodation", locals: { accommodation: @accommodation }
  end

  # POST or PATCH /projects/1/accommodations
  def save_accommodation
    @project = Project.find_by(id: params[:id])
    @accommodation_params = accommodation_params

    if params[:accommodation_id].present?
      # Find the existing accommodation to update
      @accommodation = @project.accommodations.find_by(id: params[:accommodation_id])
      if @accommodation.update(@accommodation_params)
        flash[:notice] = "Accommodation updated successfully!"
      else
        flash[:alert] = "Failed to update accommodation."
      end
    else
      # Create a new accommodation
      @accommodation = @project.accommodations.build(@accommodation_params)
      if @accommodation.save
        flash[:notice] = "Accommodation added successfully!"
      else
        flash[:alert] = "Failed to add accommodation."
      end
    end

    respond_to do |format|
      if @accommodation.errors.empty?
        format.json do
          render json: {
            status: "success",
            redirect_url: project_path(@project, tab: "accommodations") # Redirect URL after save
          }
        end
      else
        # Determine which form to re-render based on the presence of accommodation_id
        form_partial = params[:accommodation_id].present? ? "projects/edit_accommodation_form" : "projects/form_accommodation"

        format.js do
          render partial: form_partial,
                 status: :unprocessable_entity,
                 locals: { accommodation: @accommodation }
        end

        format.json { render json: @accommodation.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_accommodation
    @project = Project.find(params[:id])
    @accommodation = @project.accommodations.find(params[:accommodation_id])
    render partial: "edit_accommodation_form", locals: { accommodation: @accommodation }
  end

  def delete_accommodation
    @project = Project.find(params[:id])
    @accommodation = @project.accommodations.find(params[:accommodation_id])

    if @accommodation.destroy
      flash[:notice] = "Accommodation deleted successfully!"
      render json: { status: "success", message: "Accommodation deleted successfully", redirect_url: project_path(@project, tab: "accommodations") }, status: :ok
    else
      flash[:alert] = "Failed to delete accommodation."
      render json: { status: "error", message: "Failed to delete accommodation" }, status: :unprocessable_entity
    end
  end

  def remove_accommodation_document
    @project = Project.find(params[:id])
    @accommodation = @project.accommodations.find(params[:accommodation_id])

    document_type = params[:document_type]

    if %w[invoice_document quotation_document].include?(document_type)
      @accommodation.update(document_type => nil)
      flash[:notice] = t("notices.delete_success", document: t("activerecord.attributes.tab_docs.#{document_type}"))
    else
      flash[:alert] = t("notices.delete_failed", document: t("activerecord.attributes.tab_docs.#{document_type}"))
    end

    redirect_to project_path(@project, tab: "accommodations")
  end

  # Add Catering Form
  def add_catering
    @catering = @project.caterings.build
    render partial: "projects/form_catering", locals: { catering: @catering }
  end

  # POST or PATCH /projects/1/caterings
  def save_catering
    @project = Project.find_by(id: params[:id])
    @catering_params = catering_params

    if params[:catering_id].present?
      # Find the existing catering to update
      @catering = @project.caterings.find_by(id: params[:catering_id])
      if @catering.update(@catering_params)
        flash[:notice] = "Catering updated successfully!"
      else
        flash[:alert] = "Failed to update catering."
      end
    else
      # Create a new catering
      @catering = @project.caterings.build(@catering_params)
      if @catering.save
        flash[:notice] = "Catering added successfully!"
      else
        flash[:alert] = "Failed to add catering."
      end
    end

    respond_to do |format|
      if @catering.errors.empty?
        format.json do
          render json: {
            status: "success",
            redirect_url: project_path(@project, tab: "catering") # Redirect URL after save
          }
        end
      else
        # Determine which form to re-render based on the presence of catering_id
        form_partial = params[:catering_id].present? ? "projects/edit_catering_form" : "projects/form_catering"

        format.js do
          render partial: form_partial,
                 status: :unprocessable_entity,
                 locals: { catering: @catering }
        end

        format.json { render json: @catering.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_catering
    @project = Project.find(params[:id])
    @catering = @project.caterings.find(params[:catering_id])
    render partial: "edit_catering_form", locals: { catering: @catering }
  end

  def delete_catering
    @project = Project.find(params[:id])
    @catering = @project.caterings.find(params[:catering_id])

    if @catering.destroy
      flash[:notice] = "Catering deleted successfully!"
      render json: { status: "success", message: "Catering deleted successfully", redirect_url: project_path(@project, tab: "catering") }, status: :ok
    else
      flash[:alert] = "Failed to delete catering."
      render json: { status: "error", message: "Failed to delete catering" }, status: :unprocessable_entity
    end
  end

  def remove_catering_document
    @project = Project.find(params[:id])
    @catering = @project.caterings.find(params[:catering_id])

    document_type = params[:document_type]

    if %w[invoice_document quotation_document].include?(document_type)
      @catering.update(document_type => nil)
      flash[:notice] = t("notices.delete_success", document: t("activerecord.attributes.tab_docs.#{document_type}"))
    else
      flash[:alert] = t("notices.delete_failed", document: t("activerecord.attributes.tab_docs.#{document_type}"))
    end

    redirect_to project_path(@project, tab: "catering")
  end

  # Add Transport Form
  def add_transport
    @transport = @project.transports.build
    render partial: "projects/form_transport", locals: { transport: @transport }
  end

  # POST or PATCH /projects/1/transports
  def save_transport
    @project = Project.find_by(id: params[:id])
    @transport_params = transport_params

    if params[:transport_id].present?
      # Find the existing transport to update
      @transport = @project.transports.find_by(id: params[:transport_id])
      if @transport.update(@transport_params)
        flash[:notice] = "Transport updated successfully!"
      else
        flash[:alert] = "Failed to update transport."
      end
    else
      # Create a new transport
      @transport = @project.transports.build(@transport_params)
      if @transport.save
        flash[:notice] = "Transport added successfully!"
      else
        flash[:alert] = "Failed to add transport."
      end
    end

    respond_to do |format|
      if @transport.errors.empty?
        format.json do
          render json: {
            status: "success",
            redirect_url: project_path(@project, tab: "transport") # Redirect URL after save
          }
        end
      else
        # Determine which form to re-render based on the presence of transport_id
        form_partial = params[:transport_id].present? ? "projects/edit_transport_form" : "projects/form_transport"

        format.js do
          render partial: form_partial,
                 status: :unprocessable_entity,
                 locals: { transport: @transport }
        end

        format.json { render json: @transport.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit_transport
    @project = Project.find(params[:id])
    @transport = @project.transports.find(params[:transport_id])
    render partial: "edit_transport_form", locals: { transport: @transport }
  end

  def delete_transport
    @project = Project.find(params[:id])
    @transport = @project.transports.find(params[:transport_id])

    if @transport.destroy
      flash[:notice] = "Transport deleted successfully!"
      render json: { status: "success", message: "Transport deleted successfully", redirect_url: project_path(@project, tab: "transport") }, status: :ok
    else
      flash[:alert] = "Failed to delete transport."
      render json: { status: "error", message: "Failed to delete transport" }, status: :unprocessable_entity
    end
  end

  def remove_transport_document
    @project = Project.find(params[:id])
    @transport = @project.transports.find(params[:transport_id])

    document_type = params[:document_type]

    if %w[invoice_document quotation_document].include?(document_type)
      @transport.update(document_type => nil)
      flash[:notice] = t("notices.delete_success", document: t("activerecord.attributes.tab_docs.#{document_type}"))
    else
      flash[:alert] = t("notices.delete_failed", document: t("activerecord.attributes.tab_docs.#{document_type}"))
    end

    redirect_to project_path(@project, tab: "transport")
  end

  def add_experts
    @project = Project.find(params[:id])
    expert_ids = params[:expert_ids]

    # Assuming you have a has_many relationship with experts
    experts = Expert.where(id: expert_ids)

    # Add experts to the project
    @project.experts << experts

    if @project.save
      render json: { success: true, message: "Experts added successfully" }
      flash[:notice] = "Experts added successfully!"
    else
      render json: { success: false, message: "Error adding experts" }, status: :unprocessable_entity
      flash[:alert] = "Failed to add experts."
    end
  end

  def unassign_expert
    @project = Project.find(params[:id])
    @expert = Expert.find(params[:expert_id])

    # Unassign the expert from the project
    @project.experts.delete(@expert) # Or use `@expert.projects.delete(@project)` if it's a many-to-many relationship

    if @project.save
      render json: { status: "success", message: "Expert has been unassigned", redirect_url: project_path(@project) }
      flash[:notice] = "Expert unassigned successfully!"
    else
      render json: { status: "error", message: "Failed to unassign expert" }, status: :unprocessable_entity
      flash[:notice] = "Failed to unassign expert"
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(
        :project_status,
        :project_name,
        :project_client,
        :execution_locations,
        :project_type,
        :project_date_from,
        :project_date_to,
        :execution_address,
        :invitation_status,
        :certificate_status,
        :project_type_id,
        :participant_list,
        :invitation_document,
        :certificate_document,
        :key_topic,
        :flight_data,
        :target_audience
      )
    end

    def partner_params
      params.require(:partner).permit(:location_name, :address, :contact, :deadline, :notes, :quotation_document, :invoice_document)
    end

    def accommodation_params
      params.require(:accommodation).permit(:name, :status, :address, :contact, :booking_deadline, :notes, :quotation_document, :invoice_document)
    end

    def catering_params
      params.require(:catering).permit(:location_name, :status, :address, :contact, :booking_deadline, :notes, :quotation_document, :invoice_document)
    end

    def transport_params
      params.require(:transport).permit(:transport_type, :company_name, :status, :booking_deadline, :contact, :notes, :quotation_document, :invoice_document)
    end


    def check_for_param_changes(filtered_params)
      filtered_params.to_h.any? do |key, value|
        # Check if the value in the project is different
        @project.read_attribute(key.to_s) != value
      end
    end

    def document_removal_requested?
      %w[participant_list invitation_document certificate_document].any? do |doc_name|
        params[:project]["remove_#{doc_name}"] == "true"
    end
  end
end
