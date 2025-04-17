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

class UpdateProjectsStructure < ActiveRecord::Migration[7.2]
  def change
    change_table :projects do |t|
      # Entfernen von nicht mehr benötigten Spalten
      t.remove :location_of_execution
      t.remove :execution_location
      t.remove :execution_address
      t.remove :invitation_status
      t.remove :certificate_status
      t.remove :project_type_id
      t.remove :client

      # Hinzufügen neuer Spalten
      t.json :key_topics
      t.date :project_date_from
      t.date :project_date_to
      t.json :project_type
      t.string :project_client
      t.json :execution_locations
      t.string :target_audience
      t.string :flight_data
    end
  end
end
