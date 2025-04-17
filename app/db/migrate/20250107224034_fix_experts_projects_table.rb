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

class FixExpertsProjectsTable < ActiveRecord::Migration[7.2]
  def change
    add_index :experts_projects, :expert_id unless index_exists?(:experts_projects, :expert_id)
    add_index :experts_projects, :project_id unless index_exists?(:experts_projects, :project_id)

    add_index :experts_projects, [ :expert_id, :project_id ], unique: true unless index_exists?(:experts_projects, [ :expert_id, :project_id ])

    remove_duplicates
  end

  private

  def remove_duplicates
    execute <<-SQL
      DELETE FROM experts_projects
      WHERE rowid NOT IN (
        SELECT MIN(rowid)
        FROM experts_projects
        GROUP BY expert_id, project_id
      )
    SQL
  end
end
