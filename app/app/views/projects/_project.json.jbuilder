json.extract! project, :id, :project_name, :client, :execution_location, :execution_address, :invitation_status, :certificate_status, :project_type_id, :created_at, :updated_at
json.url project_url(project, format: :json)
