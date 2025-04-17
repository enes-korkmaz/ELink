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

require "application_system_test_case"

class ProjectsTest < ApplicationSystemTestCase
  setup do
    @project = projects(:project_one)
    @user2 = users(:employee)
    login_as_employee(@user2)
    @partner = partners(:partner_one)
    @expert = experts(:one)
  end

  def login_as_employee(user2)
    visit login_path
    fill_in "username", with: user2.username
    fill_in "password", with: "employee123"
    click_on I18n.t("login.sign_in")

    # Verify that the user is redirected to the home page
    assert_current_path(root_path)
  end

  test "visiting the index" do
    visit projects_url
    # assert_selector "h1", text: I18n.t("projects.index.title")
  end

  test "should create project" do
    visit projects_url
    click_on I18n.t("actions.create")

    fill_in "project[project_name]", with: "New Project"
    fill_in "project[project_date_from]", with: Date.today
    fill_in "project[project_date_to]", with: Date.today + 30
    fill_in "project[project_client]", with: "Client X"
    fill_in "project[execution_locations]", with: "Secret Location"

    project_types = ProjectType.all
    project_types.each do |type|
      check "project_type_#{type.id}"
    end

    key_topics = KeyTopic.all
    key_topics.each do |topic|
      check "key_topic_#{topic.id}"
    end

    click_on I18n.t("actions.create")
    assert_text I18n.t("notices.project_created_success")
  end

  test "should update project" do
    visit project_url(@project)
    click_on I18n.t("actions.edit"), match: :first

    fill_in "project[project_name]", with: @project.project_name

    click_on I18n.t("actions.update")
    assert_text I18n.t("notices.update_success")
    click_on I18n.t("actions.back")
  end

  test "should destroy project" do
    visit project_url(@project)
    find("[data-testid='delete-project-#{@project.id}']").click

    begin
      alert = page.driver.browser.switch_to.alert
      assert_equal I18n.t("actions.project.confirm_delete"), alert.text
      alert.accept
    rescue Selenium::WebDriver::Error::NoSuchAlertError
      # Its axpected in a test setup that sometimes the Dialog isnt found
      puts "Accepted automaticly."
    end

    assert page.has_text?(I18n.t("notices.project_destroy"))

    assert_raises(ActiveRecord::RecordNotFound) do
      Project.find(@project.id)
    end
  end

  # Test: Add a Partner
  test "should add partner to project" do
    visit project_url(@project)

    # Ensure we are on the "Partners" tab (navigate to the Partners tab first if it's not the default)
    click_on I18n.t("tabs.partners"), match: :first

    click_on I18n.t("actions.add")

    fill_in "partner[location_name]", with: "New Partner Location"
    fill_in "partner[address]", with: "123 Partner Street"
    fill_in "partner[contact]", with: "1234567890"
    fill_in "partner[deadline]", with: Date.today + 7
    fill_in "partner[notes]", with: "Partner details here."

    click_on I18n.t("actions.save")
    assert_text "Partner added successfully!"
    assert_current_path project_path(@project, tab: "partners")
  end

  # Test: Edit a Partner
  test "should edit partner details" do
    visit project_url(@project)

    # Ensure we are on the "Partners" tab (navigate to the Partners tab first if it's not the default)
    click_on I18n.t("tabs.partners"), match: :first

    # Locate the "Edit" button using its data-id attribute, dynamically using @partner.id
    partner_edit_button = find("button[data-url='#{edit_partner_project_path(@project, partner_id: @partner.id)}']")
    partner_edit_button.click

    # Fill in updated partner details and submit the form
    fill_in "partner[location_name]", with: "Updated Partner Location"
    fill_in "partner[address]", with: "456 Updated Street"
    fill_in "partner[contact]", with: "1234567890"
    fill_in "partner[deadline]", with: (Date.today + 10).to_s
    fill_in "partner[notes]", with: "Updated partner details"

    click_on I18n.t("actions.save")  # This is the button text that saves the form

    # Assert that the partner was updated
    assert_text "Partner updated successfully!"  # Replace with the actual success message in your form
  end


  # Test: Delete a Partner
  test "should delete partner from project" do
    visit project_url(@project)

    # Ensure we are on the "Partners" tab
    click_on I18n.t("tabs.partners"), match: :first

    # Locate the delete button using the partner's ID dynamically
    partner_delete_button = find("button[data-url='#{delete_partner_project_path(@project, partner_id: @partner.id)}']")

    assert partner_delete_button.present?, "Delete button not found"
    partner_delete_button.click

    # Accept the alert
    accept_alert

    # Optionally, check if the success message appears
    assert_text "Partner deleted successfully!"
  end

test "should add experts to project" do
  visit project_url(@project)

  within("#tabs-navigation") do
    click_on I18n.t("tabs.experts")
  end

  assert_current_path("/projects/672619541?tab=expert")

  click_on I18n.t("actions.add")

  assert_current_path experts_path(mode: "add_to_project", project_id: @project.id)

  assert_selector(".expert-checkbox", visible: true, wait: 5)

  assert page.has_selector?(".expert-checkbox"), "Expert checkboxes should be visible"

  find("input.expert-checkbox", match: :first).set(true)


  click_on I18n.t("actions.add_to_project")

  assert_text "Experts added successfully!"

  assert_current_path project_path(@project, tab: "expert")

  assert_text I18n.t("activerecord.attributes.expert.hourly_rate")
end

# Test: Delete a Partner
test "should unassign expert from project" do
  visit project_url(@project)

  within("#tabs-navigation") do
    click_on I18n.t("tabs.experts")
  end

  expert_unassign_button = find("button[title='#{I18n.t('actions.unassign')}']")


  assert expert_unassign_button.present?, "Unassign button not found"
  expert_unassign_button.click

  # Accept the confirmation alert
  accept_alert

  # Optionally, check if the success message appears
  assert_text "Expert unassigned successfully!"
end
end
