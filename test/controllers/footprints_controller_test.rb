require "test_helper"

class FootprintsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @footprint = footprints(:one)
  end

  test "should get index" do
    get footprints_url
    assert_response :success
  end

  test "should get new" do
    get new_footprint_url
    assert_response :success
  end

  test "should create footprint" do
    assert_difference('Footprint.count') do
      post footprints_url, params: { footprint: {  } }
    end

    assert_redirected_to footprint_url(Footprint.last)
  end

  test "should show footprint" do
    get footprint_url(@footprint)
    assert_response :success
  end

  test "should get edit" do
    get edit_footprint_url(@footprint)
    assert_response :success
  end

  test "should update footprint" do
    patch footprint_url(@footprint), params: { footprint: {  } }
    assert_redirected_to footprint_url(@footprint)
  end

  test "should destroy footprint" do
    assert_difference('Footprint.count', -1) do
      delete footprint_url(@footprint)
    end

    assert_redirected_to footprints_url
  end
end
