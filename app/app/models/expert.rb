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

class Expert < ApplicationRecord
  enum :salutation, { mr: 1, ms: 2, mx: 3 }

  has_and_belongs_to_many :languages, join_table: :experts_languages
  has_and_belongs_to_many :categories, join_table: :categories_experts
  has_many :experts_projects
  has_many :projects, through: :experts_projects

  belongs_to :language

  has_one :user

  # documents
  has_one_attached :profile_picture
  has_one_attached :resume
  has_many_attached :certificates

  validates :resume, presence: true

  validates :salutation, :first_name, :last_name, :nationality, :phone_number,
            :current_location, :language, :languages, :hourly_rate, :daily_rate,
            :spontaneous, :categories, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone_number, format: { with: /\A\+[\d\s()-]{4,16}\z/ }
  validates :hourly_rate, :daily_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :institution_name, presence: true, if: -> { has_institution? }
  validates :china_reference, presence: true, if: -> { has_china_reference? }
  validates :travel_willingness_text, :cooperation_options, :china_reference, length: { maximum: 125 }
  validates :free_text, length: { maximum: 500 }

  validate :validate_extra_skills_format, if: -> { extra_skills.present? }

  validate :must_have_travel_willingness

  private
  def must_have_travel_willingness
    unless travel_willingness_online || travel_willingness_germany || travel_willingness_china
      errors.add(:base,  I18n.t("activerecord.errors.models.expert.attributes.travel_willingness.blank"))
    end
  end

  def validate_extra_skills_format
    return if extra_skills.blank?

    skills = extra_skills.split(",").map(&:strip)

    if skills.size > 20
      excess = skills.size - 20
      errors.add(:extra_skills, :too_many_skills, count: excess)
    end

    # Check each individual skill
    skills.each do |skill|
      # Check for length first
      if skill.length < 2 || skill.length > 30
        errors.add(:extra_skills, :too_short_or_too_long)
      elsif !skill.match?(/\A[a-zA-ZäöüÄÖÜß0-9 ]+\z/)
        # Check for invalid characters (no commas, no spaces at the beginning or end, etc.)
        errors.add(:extra_skills, :invalid)
      end
    end

    # Check if the input contains the correct delimiters (no leading/trailing commas or more than one comma)
    if extra_skills.match?(/^,.*$|.*,.*,$|^\s*$|^[,]+$/)
      errors.add(:extra_skills, :format)
    end
  end
end
