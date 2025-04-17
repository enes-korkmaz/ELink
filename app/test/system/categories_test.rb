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

class CategoriesTest < ApplicationSystemTestCase
  setup do
    @category = categories(:category_one)
    @user  = users(:employee)
    login_as_employee(@user)
  end

  def login_as_employee(user)
    visit login_path
    fill_in "username", with: user.username
    fill_in "password", with: "employee123"
    click_on I18n.t("login.sign_in")

    assert_current_path(root_path)
  end

  test "should create category" do
    visit new_category_url

    assert_selector "input#new_category_field", visible: true
    fill_in "new_category_field", with: @category.name
    click_on "add_category_button"

    assert_text I18n.t("flash.category_created")
  end

  test "should create category with leading and trailing by trimming" do
    visit new_category_url

    assert_selector "input#new_category_field", visible: true
    fill_in "new_category_field", with: "  leadingAndTraillingSpaces  "
    assert_selector "input#new_category_field:valid"
    click_on "add_category_button"

    assert_text I18n.t("flash.category_created")
    assert_text "leadingAndTraillingSpaces"
  end

  test "should not create category with short name" do
    visit new_category_url

    assert_selector "input#new_category_field", visible: true
    fill_in "new_category_field", with: "A"
    assert_selector "input#new_category_field:invalid"

    within("#add_category_button") do
      assert_no_selector("button[disabled]", wait: 2)
    end
  end

  test "should not create category with punctuation mark in name" do
    visit new_category_url

    assert_selector "input#new_category_field", visible: true
    fill_in "new_category_field", with: "AA,"
    assert_selector "input#new_category_field:invalid"

    within("#add_category_button") do
      assert_no_selector("button[disabled]", wait: 2)
    end
  end

  test "should not create category with to long name" do
    visit new_category_url

    assert_selector "input#edit_category_name", visible: true
    fill_in "edit_category_name", with: "toManyCharactersInNameShouldFail"
    assert_selector "input#new_category_field:invalid"

    within("#save_category_button") do
      assert_no_selector("button[disabled]", wait: 2)
    end
  end

  test "edit category field should be valid with leading and trailing spaces in name" do
    visit new_category_url

    assert_selector "input#edit_category_name", visible: true
    fill_in "edit_category_name", with: "  leadingAndTraillingSpaces  "
    assert_selector "input#edit_category_name:valid"
  end

  test "edit category field should be invalid with short name" do
    visit new_category_url

    assert_selector "input#edit_category_name", visible: true
    fill_in "edit_category_name", with: "A"
    assert_selector "input#edit_category_name:invalid"

    within("#save_category_button") do
      assert_no_selector("button[disabled]", wait: 2)
    end
  end

  test "edit category field should be invalid with punctuation mark in name" do
    visit new_category_url

    assert_selector "input#edit_category_name", visible: true
    fill_in "edit_category_name", with: "AA,"
    assert_selector "input#edit_category_name:invalid"

    within("#save_category_button") do
      assert_no_selector("button[disabled]", wait: 2)
    end
  end

  test "edit category field should be invalid with to long category name" do
    visit new_category_url

    assert_selector "input#edit_category_name", visible: true
    fill_in "edit_category_name", with: "toManyCharactersInNameShouldFail"
    assert_selector "input#edit_category_name:invalid"

    within("#save_category_button") do
      assert_no_selector("button[disabled]", wait: 2)
    end
  end
end
