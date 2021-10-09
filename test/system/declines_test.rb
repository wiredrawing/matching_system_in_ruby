require "application_system_test_case"

class DeclinesTest < ApplicationSystemTestCase
  setup do
    @decline = declines(:one)
  end

  test "visiting the index" do
    visit declines_url
    assert_selector "h1", text: "Declines"
  end

  test "creating a Decline" do
    visit declines_url
    click_on "New Decline"

    click_on "Create Decline"

    assert_text "Decline was successfully created"
    click_on "Back"
  end

  test "updating a Decline" do
    visit declines_url
    click_on "Edit", match: :first

    click_on "Update Decline"

    assert_text "Decline was successfully updated"
    click_on "Back"
  end

  test "destroying a Decline" do
    visit declines_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Decline was successfully destroyed"
  end
end
