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

class SessionsControllerTest < ActionDispatch::IntegrationTest
  # Set up a valid user for testing login
  setup do
    @user = users(:employee) # Assuming you have a fixture with a user named 'employee'
  end

  # Test if the login page is accessible
  test "should get new" do
    get login_url
    assert_response :success
  end

  # Test successful login with valid credentials
  test "should create session with valid credentials" do
    post login_url, params: { username: @user.username, password: "employee123" }
    assert_redirected_to root_path
    follow_redirect!

    # Ensure the user is logged in by checking session
    assert_equal @user.id, session[:user_id]
    assert_equal I18n.t("login.welcome_role", role: @user.role), flash[:notice] # Ensure flash message is correct
  end

  # Test unsuccessful login with invalid credentials
  test "should not create session with invalid credentials" do
    post login_url, params: { username: "wrong_user", password: "wrong_pass" }
    assert_redirected_to login_path
    assert_nil session[:user_id]  # Ensure session is not set
    assert_equal I18n.t("login.invalid_credentials"), flash[:alert]  # Ensure flash message is correct
  end

  # Test logout functionality
  test "should destroy session on logout" do
    # Log in first
    post login_url, params: { username: @user.username, password: "employee123" }
    assert_equal @user.id, session[:user_id]  # Ensure user is logged in

    # Now logout
    delete logout_url
    assert_redirected_to login_path
    assert_nil session[:user_id]  # Ensure session is cleared
    assert_equal I18n.t("login.logged_out"), flash[:notice]  # Ensure flash message is correct
  end

  # Test that accessing restricted area without login redirects to login page
  test "should redirect to login if not logged in" do
    get root_path
    assert_redirected_to login_path
    assert_equal I18n.t("flash.login_required"), flash[:alert]
  end

  teardown do
    delete logout_path
  end
end
