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

class User < ApplicationRecord
  has_secure_password

  belongs_to :expert, optional: true

  validates :username, presence: true, uniqueness: true
  validates :role, presence: true

  def self.generate_registration_token
    payload = {
      exp: (Time.now + 7.days).to_i
    }
    JWT.encode(payload, ENV.fetch("SECRET_KEY_BASE"))
  end

  def self.decode_registration_token(token)
    JWT.decode(token, ENV.fetch("SECRET_KEY_BASE"), true, { algorithm: "HS256" })
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    puts "JWT decoding error: #{e.class} - #{e.message}"
    nil
  end

  def expert
    @_expert ||= Expert.find_by(user_id: id)
  end
end
