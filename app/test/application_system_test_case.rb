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

require "test_helper"
require "capybara/rails"
require "capybara/minitest"
require "capybara-screenshot"
require "selenium/webdriver"
require "webdrivers"

Webdrivers::Chromedriver.required_version = ENV.fetch("CHROMEDRIVER_VERSION", nil)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1920, 1080 ] do |driver|
    driver.add_argument("--headless")
    driver.add_argument("--no-sandbox")
    driver.add_argument("--disable-dev-shm-usage")
    driver.add_argument("--disable-gpu")
    driver.add_argument("--window-size=1400x1400")
  end

  def setup
      super
      Selenium::WebDriver::Chrome::Service.driver_path = "/usr/local/bin/chromedriver"
  end
end

Capybara.default_max_wait_time = 20
Capybara::Screenshot.autosave_on_failure = true
