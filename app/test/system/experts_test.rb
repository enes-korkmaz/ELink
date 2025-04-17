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

# overview of attributes *-means requiered
#   salutation*, title, first_name* & last_name*
#   nationality*
#   phone_number* & email*
#   current_location*
#   communication language AS language*
#   languages of instruction AS languages*
#   hourly_rate* default 0
#   daily_rate* default 0
#   one of these has to be checked - travel_willingness_online*, travel_willingness_germany* & travel_willingness_china*
#   travel_willingness_text
#   spontaneous*
#   has_china_ref
#   # only mandatory if has_china_ref
#   china_reference*
#   categories*
#   extra_skills
#   has_institution
#   # only mandatory if has_institution
#   institution_name*
#   cooperation_options
#   free_text
class ExpertsTest < ApplicationSystemTestCase
  setup do
    # this expert has all attributes filled and or selected
    @expert_all_attributes = experts(:thriteen)

    # this expert has not all attributes filled and or selected
    @expert_not_all_attribute = experts(:fourteen)

    # Setting up a user with the appropriate role for testing
    @user2  = users(:employee)
    login_as_employee(@user2)

    # Attaching mendetory File
    @expert_not_all_attribute.resume.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "resume_test.pdf")),
                                        filename: "resume_test.pdf",
                                        content_type: "application/pdf")
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
    visit experts_url
    assert_current_path(experts_url)
  end

  test "should create expert without errors" do
    visit experts_url
    # only valid as long as placeholder button still in view (will be moved to root_path)
    click_on I18n.t("actions.create")

    salutation_display_text = {
      "mr" => I18n.t("activerecord.attributes.expert.salutations.mr"),
      "ms" => I18n.t("activerecord.attributes.expert.salutations.ms"),
      "mx" => I18n.t("activerecord.attributes.expert.salutations.mx")
    }
    select salutation_display_text[@expert_all_attributes.salutation], from: "expert[salutation]"

    fill_in "expert[title]", with: @expert_all_attributes.title
    fill_in "expert[first_name]", with: @expert_all_attributes.first_name
    fill_in "expert[last_name]", with: @expert_all_attributes.last_name

    fill_in "expert[nationality]", with: @expert_all_attributes.nationality

    fill_in "expert[phone_number]", with: @expert_all_attributes.phone_number
    fill_in "expert[email]", with: @expert_all_attributes.email

    fill_in "expert[current_location]", with: @expert_all_attributes.current_location

    # communication language (one value)
    language_display_text = I18n.t("language_names.#{@expert_all_attributes.language.language.downcase}")
    select language_display_text, from: "expert[language_id]"

    # lecture languages
    Array(@expert_all_attributes.language_ids).each do |language_id|
      check "language_#{language_id}" if language_id.present?
    end

    fill_in "expert[hourly_rate]", with: @expert_all_attributes.hourly_rate
    fill_in "expert[daily_rate]", with: @expert_all_attributes.daily_rate

    skills = @expert_all_attributes.extra_skills.split(", ").map(&:strip)

    # Checking, if it was added to visible list
    skills.each do |skill|
      fill_in "new_extra_skill_field", with: skill
      click_button "add_extra_skill_button"
    end

    # Checking, if it was added to actuall hidden form field
    hidden_field = find("#extra_skill_text_field", visible: false)
    skills.each do |skill|
      assert_includes hidden_field.value, skill, "Skill '#{skill}' wurde nicht im versteckten Feld gespeichert."
    end

    check "expert[travel_willingness_online]" if @expert_all_attributes.travel_willingness_online.present?
    check "expert[travel_willingness_germany]" if @expert_all_attributes.travel_willingness_germany.present?
    check "expert[travel_willingness_china]" if @expert_all_attributes.travel_willingness_china.present?
    fill_in "expert[travel_willingness_text]", with: @expert_all_attributes.travel_willingness_text

    fill_in "expert[spontaneous]", with: @expert_all_attributes.spontaneous

    check "expert[has_china_reference]" if @expert_all_attributes.has_china_reference.present?

    fill_in "expert[china_reference]", with: @expert_all_attributes.china_reference
    # maybe check for char counter - assert to "48/125"
    Array(@expert_all_attributes.category_ids).each do |category_id|
      check "category_#{category_id}" if category_id.present?
    end

    check "expert[has_institution]" if @expert_all_attributes.has_institution.present?

    fill_in "expert[institution_name]", with: @expert_all_attributes.institution_name

    fill_in "expert[cooperation_options]", with: @expert_all_attributes.cooperation_options

    fill_in "expert[free_text]", with: @expert_all_attributes.free_text

    # maybe assign to projects

    click_on I18n.t("actions.create")
    # assert_text I18n.t("notices.expert_created_success")

    created_expert = Expert.last
    assert_equal @expert_all_attributes.travel_willingness_online, created_expert.travel_willingness_online
    assert_equal @expert_all_attributes.travel_willingness_germany, created_expert.travel_willingness_germany
    assert_equal @expert_all_attributes.travel_willingness_china, created_expert.travel_willingness_china

    assert_equal @expert_all_attributes.salutation, created_expert.salutation
    assert_equal @expert_all_attributes.title, created_expert.title
    assert_equal @expert_all_attributes.first_name, created_expert.first_name
    assert_equal @expert_all_attributes.last_name, created_expert.last_name
    assert_equal @expert_all_attributes.nationality, created_expert.nationality
    assert_equal @expert_all_attributes.phone_number, created_expert.phone_number
    assert_equal @expert_all_attributes.email, created_expert.email
    assert_equal @expert_all_attributes.current_location, created_expert.current_location
    # communication language
    assert_equal @expert_all_attributes.language_id, created_expert.language_id
    assert_equal @expert_all_attributes.hourly_rate, created_expert.hourly_rate
    assert_equal @expert_all_attributes.daily_rate, created_expert.daily_rate
    assert_equal @expert_all_attributes.extra_skills, created_expert.extra_skills
    assert_equal @expert_all_attributes.travel_willingness_online, created_expert.travel_willingness_online
    assert_equal @expert_all_attributes.travel_willingness_germany, created_expert.travel_willingness_germany
    assert_equal @expert_all_attributes.travel_willingness_china, created_expert.travel_willingness_china
    assert_equal @expert_all_attributes.travel_willingness_text, created_expert.travel_willingness_text
    assert_equal @expert_all_attributes.spontaneous, created_expert.spontaneous
    assert_equal @expert_all_attributes.china_reference, created_expert.china_reference
    assert_equal @expert_all_attributes.has_institution, created_expert.has_institution
    assert_equal @expert_all_attributes.institution_name, created_expert.institution_name
    assert_equal @expert_all_attributes.cooperation_options, created_expert.cooperation_options
    assert_equal @expert_all_attributes.free_text, created_expert.free_text

    # assertions for many-to-many-relations (ex. categories, languages)
    assert_equal @expert_all_attributes.language_ids.sort, created_expert.language_ids.sort
    assert_equal @expert_all_attributes.category_ids.sort, created_expert.category_ids.sort
  end

  test "should not create expert without requiered attributes" do
    pseudo_email_wrong_format = "wrong_format.com"
    not_a_number = "Not_Number"
    neagtive_number = "-1"

    visit new_expert_path
    click_on I18n.t("actions.create")

    # Verify that the user was not redirected - not a good test case because rails does redirect by standart
    assert_current_path(experts_path)

    # Check for alert header
    assert_text I18n.t("activerecord.errors.models.expert.header")

    # Check for alerts that notify to fill in information
    assert_text I18n.t("activerecord.errors.models.expert.attributes.first_name.blank")
    assert_text I18n.t("activerecord.errors.models.expert.attributes.last_name.blank")
    assert_text I18n.t("activerecord.errors.models.expert.attributes.email.blank")
    assert_text I18n.t("activerecord.errors.models.expert.attributes.phone_number.blank")
    assert_text I18n.t("activerecord.errors.models.expert.attributes.current_location.blank")
    assert_text I18n.t("activerecord.errors.models.expert.attributes.nationality.blank")
    assert_text I18n.t("activerecord.errors.models.expert.attributes.language.blank")
    assert_text I18n.t("activerecord.errors.models.expert.attributes.categories.blank")
    assert_no_text I18n.t("activerecord.errors.models.expert.attributes.hourly_rate.blank")
    assert_no_text I18n.t("activerecord.errors.models.expert.attributes.daily_rate.blank")
    assert_text I18n.t("activerecord.errors.models.expert.attributes.travel_willingness.blank")

    fill_in "expert[email]", with: pseudo_email_wrong_format
    # It should not be possible to input anything but numbers or -/+
    fill_in "expert[hourly_rate]", with: not_a_number
    fill_in "expert[daily_rate]", with: not_a_number

    click_on I18n.t("actions.create")

    assert_current_path(experts_path)

    # Check for alerts that notify that what was filled in is invalid
    assert_text I18n.t("activerecord.errors.models.expert.attributes.email.invalid")
    assert_no_text I18n.t("activerecord.errors.models.expert.attributes.hourly_rate.not_a_number")
    assert_no_text I18n.t("activerecord.errors.models.expert.attributes.daily_rate.not_a_number")

    fill_in "expert[email]", with: @expert_all_attributes.email
    fill_in "expert[hourly_rate]", with: neagtive_number
    fill_in "expert[daily_rate]", with: neagtive_number

    click_on I18n.t("actions.create")

    assert_current_path(experts_path)

    # Check if previos alert disappered after correct input / different input
    assert_no_text I18n.t("activerecord.errors.models.expert.attributes.email.invalid")
    # diffrent but still invalid input
    assert_no_text I18n.t("activerecord.errors.models.expert.attributes.hourly_rate.not_a_number")
    assert_no_text I18n.t("activerecord.errors.models.expert.attributes.daily_rate.not_a_number")
    # Check for alerts that notify that what was filled in is invalid
    assert_text I18n.t("activerecord.errors.models.expert.attributes.hourly_rate.greater_than_or_equal_to")
    assert_text I18n.t("activerecord.errors.models.expert.attributes.daily_rate.greater_than_or_equal_to")
  end

  test "should update Expert" do
    pseudo_travel_willingness_text = "Local"
    pseudo_institute_name = "Tencent"
    pseudo_phone_number = "+49 172 9968532"
    visit expert_url(@expert_not_all_attribute)
    click_on I18n.t("actions.edit"), match: :first

    assert_equal @expert_not_all_attribute.travel_willingness_text, ""
    assert_equal @expert_not_all_attribute.has_institution, false
    assert_equal @expert_not_all_attribute.institution_name, ""

    fill_in "expert[travel_willingness_text]", with: pseudo_travel_willingness_text
    check "expert[has_institution]"
    fill_in "expert[institution_name]", with: pseudo_institute_name
    fill_in "expert[phone_number]", with: pseudo_phone_number

    click_on "expert_edit_save_button"
    assert_text I18n.t("flash.expert_updated")

    @expert_not_all_attribute.reload

    assert_equal @expert_not_all_attribute.travel_willingness_text, pseudo_travel_willingness_text
    assert_equal @expert_not_all_attribute.has_institution, true
    assert_equal @expert_not_all_attribute.institution_name, pseudo_institute_name
  end

  test "should destroy Expert" do
    visit expert_url(@expert_not_all_attribute)
    click_on I18n.t("actions.delete"), match: :first

    begin
      alert = page.driver.browser.switch_to.alert
      assert_equal I18n.t("actions.expert.confirm_delete"), alert.text
      alert.accept
    rescue Selenium::WebDriver::Error::NoSuchAlertError
      # Its axpected in a test setup that sometimes the Dialog isnt found
      puts "Accepted automaticly."
    end

    assert page.has_text?(I18n.t("flash.expert_destroyed"))

    assert_raises(ActiveRecord::RecordNotFound) do
      Expert.find(@expert_not_all_attribute.id)
    end
  end
end
