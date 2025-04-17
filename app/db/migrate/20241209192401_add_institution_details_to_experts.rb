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

class AddInstitutionDetailsToExperts < ActiveRecord::Migration[7.2]
  def change
    rename_column :experts, :institution, :institution_name

    add_column :experts, :has_institution, :boolean, null: false, default: false
    add_column :experts, :cooperation_options, :text

    # Backup consistency check  at database level (also checked at model level)
    add_check_constraint :experts, "(has_institution = false OR (has_institution = true AND institution_name IS NOT NULL))", name: "institution_name_presence"
  end
end
