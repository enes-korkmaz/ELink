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

require 'yaml'

def load_locale_files
  files = Dir.glob('./config/locales/*.yml')
  files.map do |file|
    [ File.basename(file, '.yml'), YAML.load_file(file) ]
  end.to_h
end

def extract_keys(hash, prefix = "")
  keys = []
  hash.each do |k, v|
    current_key = prefix.empty? ? k.to_s : "#{prefix}.#{k}"
    if v.is_a?(Hash)
      keys.concat(extract_keys(v, current_key))
    else
      keys << current_key
    end
  end
  keys
end

locales = load_locale_files
base_keys = nil
base_locale = nil
differences = []

locales.each do |locale, content|
  language_code = content.keys.first
  current_keys = extract_keys(content[language_code])

  if base_keys.nil?
    base_keys = current_keys
    base_locale = locale
  else
    missing_keys = base_keys - current_keys
    extra_keys = current_keys - base_keys

    if missing_keys.any? || extra_keys.any?
      differences << {
        locale: locale,
        missing_keys: missing_keys,
        extra_keys: extra_keys
      }
    end
  end
end

if differences.any?
  differences.each do |diff|
    puts "Differences in #{diff[:locale]} compared to #{base_locale}:"
    if diff[:missing_keys].any?
      puts "  Missing keys:"
      diff[:missing_keys].each { |key| puts "    - #{key}" }
    end
    if diff[:extra_keys].any?
      puts "  Extra keys:"
      diff[:extra_keys].each { |key| puts "    - #{key}" }
    end
  end
  exit 1
end

puts "All locale files have matching keys."
exit 0
