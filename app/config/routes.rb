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

Rails.application.routes.draw do
  resources :projects do
    member do
      # Document Removal
      patch "remove_document"

      # Partner Management
      get "add_partner", to: "projects#add_partner"
      post "save_partner"
      get "edit_partner", to: "projects#edit_partner"
      patch "save_partner", to: "projects#save_partner"
      delete "delete_partner", to: "projects#delete_partner"
      get "remove_partner_document", to: "projects#remove_partner_document"

      # Accommodation Management
      get "add_accommodation", to: "projects#add_accommodation"
      post "save_accommodation"
      get "edit_accommodation", to: "projects#edit_accommodation"
      patch "save_accommodation", to: "projects#save_accommodation"
      delete "delete_accommodation", to: "projects#delete_accommodation"
      get "remove_accommodation_document", to: "projects#remove_accommodation_document"

      # Catering Management
      get "add_catering", to: "projects#add_catering"
      post "save_catering"
      get "edit_catering", to: "projects#edit_catering"
      patch "save_catering", to: "projects#save_catering"
      delete "delete_catering", to: "projects#delete_catering"
      get "remove_catering_document", to: "projects#remove_catering_document"

      # Transport Management
      get "add_transport", to: "projects#add_transport"
      post "save_transport"
      get "edit_transport", to: "projects#edit_transport"
      patch "save_transport", to: "projects#save_transport"
      delete "delete_transport", to: "projects#delete_transport"
      get "remove_transport_document", to: "projects#remove_transport_document"

      post "add_experts", to: "projects#add_experts"
      delete "unassign_expert/:expert_id", to: "projects#unassign_expert", as: :unassign_expert
    end
  end

  # Registration
  get "register/:token",
    to: "registrations#new",
    constraints: { token: %r{[^/]+} },
    as: "register"

  post "register/:token",
    to: "registrations#create",
    constraints: { token: %r{[^/]+} }

  resources :project_types
  resources :key_topics
  resources :categories

  resources :experts
  root "home#overview"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "home/overview", to: "home#overview", as: "home_overview"
  # Routes for login, logout, and sessions management
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"

  get "sessions/destroy"
  delete "logout", to: "sessions#destroy"

  # Additional routes
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Calendar routes
  get "calendar/month", to: "calendar#month"
end
