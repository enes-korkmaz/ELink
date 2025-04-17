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

class Project < ApplicationRecord
  has_many :experts_projects
  has_many :experts, through: :experts_projects
  has_and_belongs_to_many :categories, join_table: :categories_projects
  has_and_belongs_to_many :documents, join_table: :documents_projects

  has_many :accommodations, dependent: :destroy
  has_many :transports, dependent: :destroy
  has_many :caterings, dependent: :destroy
  has_many :partners, dependent: :destroy
  has_one :schedule, dependent: :destroy

  # Active Storage
  has_one_attached :participant_list
  has_one_attached :invitation_document
  has_one_attached :certificate_document

  enum invitation_status: { in_progress: 0, sent: 1 }, _prefix: :invitation
  enum certificate_status: { in_progress: 0, sent: 1 }, _prefix: :certificate

  enum project_status: {
  planning: 0,
  in_progress: 1,
  blocked: 2,
  review: 3,
  completed: 4,
  cancelled: 5
  }

  validates :project_status, :invitation_status, :certificate_status, :project_name,
            :project_type, :key_topic, :project_client, :execution_locations,
            :project_type, presence: true

  validate :validate_project_type_format
  validate :validate_key_topic_format

  private
    def validate_project_type_format
      return if project_type.blank?

      types = project_type.split(",").map(&:strip)

      if types.size > 15
        excess = types.size - 15
        errors.add(:project_type, :too_many_types, count: excess)
      end

      # Check each individual type
      types.each do |type|
        # Check for length first
        if type.length < 2 || type.length > 30
          errors.add(:project_type, :too_short_or_too_long)
        elsif !type.match?(/\A[a-zA-ZäöüÄÖÜß0-9 ]+\z/)
          # Check for invalid characters (no commas, no spaces at the beginning or end, etc.)
          errors.add(:project_type, :invalid)
        end
      end

      # Check if the input contains the correct delimiters (no leading/trailing commas or more than one comma)
      if project_type.match?(/^,.*$|.*,.*,$|^\s*$|^[,]+$/)
        errors.add(:project_type, :format)
      end
    end

    def validate_key_topic_format
      return if key_topic.blank?

      topics = key_topic.split(",").map(&:strip)

      if topics.size > 15
        excess = topics.size - 15
        errors.add(:key_topic, :too_many_topics, count: excess)
      end

      # Check each individual type
      topics.each do |topic|
        # Check for length first
        if topic.length < 2 || topic.length > 30
          errors.add(:key_topic, :too_short_or_too_long)
        elsif !topic.match?(/\A[a-zA-ZäöüÄÖÜß0-9 ]+\z/)
          # Check for invalid characters (no commas, no spaces at the beginning or end, etc.)
          errors.add(:key_topic, :invalid)
        end
      end

      # Check if the input contains the correct delimiters (no leading/trailing commas or more than one comma)
      if key_topic.match?(/^,.*$|.*,.*,$|^\s*$|^[,]+$/)
        errors.add(:key_topic, :format)
      end
    end
end
