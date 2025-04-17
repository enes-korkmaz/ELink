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

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee_user = users(:employee) # Fixture for an employee user
    @intern_user = users(:intern)     # Fixture for an intern user
    @expert_user = users(:expert_thriteen)     # Fixture for an expert user
  end

  # Test non-logged-in user redirection
  test "should redirect to login when not logged in" do
    get home_overview_url
    assert_redirected_to login_path
    assert_equal I18n.t("flash.login_required"), flash[:alert]
  end

  # Test access for an employee
  test "should allow access for employee" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    get home_overview_url
    assert_response :success
  end

  # Test access for an intern
  test "should allow access for intern" do
    post login_path, params: { username: @intern_user.username, password: "intern123" }
    get home_overview_url
    assert_response :success
  end

  # Test access for an expert
  test "should restrict access for expert" do
    post login_path, params: { username: @expert_user.username, password: "expert123" }
    get home_overview_url
    assert_redirected_to expert_path(@expert_user.expert)
    assert_equal I18n.t("flash.access_denied2"), flash[:alert]
  end

  # Button tests for employee
  test "should redirect to Expert Browser when employee clicks button" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    get home_overview_url
    get experts_url # Simulating the redirection
    assert_response :success
  end

  test "should redirect to Project Browser when employee clicks button" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    get home_overview_url
    get projects_url # Simulating the redirection
    assert_response :success
  end

  test "should redirect to Create new Expert when employee clicks button" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    get home_overview_url
    get new_expert_url # Simulating the redirection
    assert_response :success
  end

  test "should redirect to Create new Project when employee clicks button" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    get home_overview_url
    get new_project_url # Simulating the redirection
    assert_response :success
  end

  # Button tests for intern (assumes intern role has same permissions for buttons)
  test "should redirect to Expert Browser when intern clicks button" do
    post login_path, params: { username: @intern_user.username, password: "intern123" }
    get home_overview_url
    get experts_url
    assert_response :success
  end

  test "should redirect to Project Browser when intern clicks button" do
    post login_path, params: { username: @intern_user.username, password: "intern123" }
    get home_overview_url
    get projects_url
    assert_response :success
  end

  test "should redirect to Create new Expert when intern clicks button" do
    post login_path, params: { username: @intern_user.username, password: "intern123" }
    get home_overview_url
    get new_expert_url
    assert_response :success
  end

  test "should redirect to Create new Project when intern clicks button" do
    post login_path, params: { username: @intern_user.username, password: "intern123" }
    get home_overview_url
    get new_project_url
    assert_response :success
  end

  # Restrict buttons for expert role
  test "should restrict expert from accessing Expert Browser" do
    post login_path, params: { username: @expert_user.username, password: "expert123" }
    get home_overview_url
    get experts_url
    assert_redirected_to expert_path(@expert_user.expert)
    assert_equal I18n.t("flash.access_denied2"), flash[:alert]
  end

  test "should restrict expert from accessing Project Browser" do
    post login_path, params: { username: @expert_user.username, password: "expert123" }
    get home_overview_url
    get projects_url
    assert_redirected_to expert_path(@expert_user.expert)
    assert_equal I18n.t("flash.access_denied2"), flash[:alert]
  end

  test "should restrict expert from accessing Create new Expert" do
    post login_path, params: { username: @expert_user.username, password: "expert123" }
    get home_overview_url
    get new_expert_url
    assert_redirected_to expert_path(@expert_user.expert)
    assert_equal I18n.t("flash.access_denied2"), flash[:alert]
  end

  test "should restrict expert from accessing Create new Project" do
    post login_path, params: { username: @expert_user.username, password: "expert123" }
    get home_overview_url
    get new_project_url
    assert_redirected_to expert_path(@expert_user.expert)
    assert_equal I18n.t("flash.access_denied2"), flash[:alert]
  end

  teardown do
    delete logout_path
  end
end
