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

class ExpertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @expert_user = users(:expert_thriteen) # Fixture for user with role 'expert'
    @employee_user = users(:employee) # Fixture for user with role 'employee'
    @expert = experts(:one) # Fixture for an existing expert
  end

  # Non-logged-in user should be redirected to login
  test "should redirect to login when not logged in" do
    get experts_url
    assert_redirected_to login_path
    assert_equal I18n.t("flash.login_required"), flash[:alert]
  end

  # Expert trying to access index should be redirected to their profile
  test "should redirect expert to their profile when accessing index" do
    post login_path, params: { username: @expert_user.username, password: "expert123" }
    get experts_url
    assert_redirected_to expert_path(@expert_user.expert)
    assert_equal I18n.t("flash.access_denied2"), flash[:alert]
  end

  # Expert trying to access new expert page should be redirected to their profile
  test "should redirect expert to their profile when accessing new expert page" do
    post login_path, params: { username: @expert_user.username, password: "expert123" }
    get new_expert_url
    assert_redirected_to expert_path(@expert_user.expert)
    assert_equal I18n.t("flash.access_denied2"), flash[:alert]
  end

  # Employee access tests: Ensure employee can perform all actions
  test "employee should get index" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    get experts_url
    assert_response :success
  end

  test "employee should get new" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    get new_expert_url
    assert_response :success
  end

  test "employee should create expert" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }

    resume_file = fixture_file_upload("test/fixtures/files/resume_test.pdf", "application/pdf")

    assert_difference("Expert.count") do
      post experts_url, params: { expert: {
        china_reference: "NewRef",
        email: "new_expert@example.com",
        extra_skills: "New skills",
        free_text: "Test expert creation",
        has_institution: true,
        institution_name: "X",
        first_name: "John",
        last_name: "Doe",
        nationality: "Test Nationality",
        phone_number: "+49 123 4567890",
        current_location: "Hier",
        daily_rate: 100,
        hourly_rate: 50,
        spontaneous: "2 Wochen",
        travel_willingness_online: true,
        travel_willingness_germany: false,
        travel_willingness_china: false,
        salutation: "mr",
        language_id: languages(:language_one).id,
        language_ids: [ languages(:language_one).id ],
        category_ids: [ categories(:category_one).id ],
        resume: resume_file
      } }
    end
    assert_redirected_to expert_url(Expert.last)
  end

  test "employee should show expert" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    get expert_url(@expert)
    assert_response :success
  end

  test "employee should get edit" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    get edit_expert_url(@expert)
    assert_response :success
  end

  test "employee should update expert" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    assert_equal @employee_user.id, session[:user_id]
    # Attaching mendetory File
    patch expert_url(@expert), params: {
      expert: {
        resume: fixture_file_upload(Rails.root.join("test", "fixtures", "files", "resume_test.pdf"), "application/pdf")
      }
    }
    assert_response :success
    assert_template :edit
    assert @expert.reload.resume.attached?

    patch expert_url(@expert), params: { expert: { first_name: "Updated" } }
    assert_response :success
    assert_template :edit
    assert_equal "Updated", @expert.reload.first_name
  end

  test "employee should destroy expert" do
    post login_path, params: { username: @employee_user.username, password: "employee123" }
    assert_difference("Expert.count", -1) do
      delete expert_url(@expert)
    end
    assert_redirected_to experts_url
  end

  teardown do
    delete logout_path
  end
end
