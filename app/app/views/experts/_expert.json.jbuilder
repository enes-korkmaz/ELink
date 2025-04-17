json.extract! expert, :salutation, :title, :first_name, :last_name,
                      :nationality, :phone_number, :email,
                      :current_location, :language_id,
                      :hourly_rate, :daily_rate,
                      :travel_willingness_online, :travel_willingness_germany,
                      :travel_willingness_china, :travel_willingness_text,
                      :spontaneous, :has_china_reference, :china_reference,
                      :extra_skills, :has_institution, :institution_name,
                      :cooperation_options, :free_text, :profile_picture,
                      :resume, :certificates, :created_at, :updated_at

json.language_ids expert.language_ids
json.category_ids expert.category_ids
json.url expert_url(expert, format: :json)
