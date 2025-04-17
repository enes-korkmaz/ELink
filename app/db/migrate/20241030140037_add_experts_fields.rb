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

class AddExpertsFields < ActiveRecord::Migration[7.2]
  def change
    rename_column :experts, :origin, :nationality
    rename_column :experts, :name, :first_name

    add_column :experts, :title, :string
    add_column :experts, :last_name, :string
    add_column :experts, :hourly_rate, :integer, default: 0
    add_column :experts, :daily_rate, :integer, default: 0
  end
end
