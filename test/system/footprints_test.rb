require "application_system_test_case"

class FootprintsTest < ApplicationSystemTestCase
  setup do
    @footprint = footprints(:one)
  end

  test "visiting the index" do
    visit footprints_url
    assert_selector "h1", text: "Footprints"
  end

  test "creating a Footprint" do
    visit footprints_url
    click_on "New Footprint"

    click_on "Create Footprint"

    assert_text "Footprint was successfully created"
    click_on "Back"
  end

  test "updating a Footprint" do
    visit footprints_url
    click_on "Edit", match: :first

    click_on "Update Footprint"

    assert_text "Footprint was successfully updated"
    click_on "Back"
  end

  test "destroying a Footprint" do
    visit footprints_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Footprint was successfully destroyed"
  end
end
