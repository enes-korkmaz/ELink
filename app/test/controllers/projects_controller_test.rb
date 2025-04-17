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

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:project_one)
    @user2 = users(:employee)
    post login_path, params: { username: @user2.username, password: "employee123" }
    @partner = partners(:partner_one) # Assuming you have a fixture for partners
  end

  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference("Project.count") do
      post projects_url, params: { project: {
        project_client: @project.project_client,
        execution_locations: @project.execution_locations,
        project_name: @project.project_name,
        project_type: @project.project_type,
        key_topic: @project.key_topic
      } }
    end

    assert_redirected_to project_url(Project.last)
  end

  test "should show project" do
    get project_url(@project)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_url(@project)
    assert_response :success
  end

  test "should update project" do
    patch project_url(@project), params: { project: {
      project_name: "Updated Project"
    } }
    assert_redirected_to project_url(@project)
  end

  test "should destroy project" do
    assert_difference("Project.count", -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
  end

  # New Test: Add a Partner to Project
  test "should add partner to project" do
    assert_difference("Partner.count", 1) do
      post save_partner_project_path(@project), params: { partner: {
        location_name: "New Partner Location"
      } }
    end
  end

  # New Test: Edit Partner in Project
  test "should edit partner in project" do
    patch save_partner_project_path(@project, partner_id: @partner.id),
    params: { partner: { location_name: "Updated Partner Location" } },
    headers: { "Accept" => "application/json" }

    assert_response :success
  end



  # New Test: Delete Partner from Project
  test "should destroy partner from project" do
    assert_difference("Partner.count", -1) do
      delete delete_partner_project_path(@project, partner_id: @partner.id)
    end

    # Check if the partner is removed and redirected correctly
    # Since you are returning JSON, assert the correct JSON response
    assert_response :success
    assert_equal "Partner deleted successfully!", JSON.parse(@response.body)["message"]
  end


  teardown do
    delete logout_path
  end
end
