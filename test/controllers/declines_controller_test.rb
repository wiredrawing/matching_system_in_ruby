require "test_helper"

class DeclinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @decline = declines(:one)
  end

  test "should get index" do
    get declines_url
    assert_response :success
  end

  test "should get new" do
    get new_decline_url
    assert_response :success
  end

  test "should create decline" do
    assert_difference('Decline.count') do
      post declines_url, params: { decline: {  } }
    end

    assert_redirected_to decline_url(Decline.last)
  end

  test "should show decline" do
    get decline_url(@decline)
    assert_response :success
  end

  test "should get edit" do
    get edit_decline_url(@decline)
    assert_response :success
  end

  test "should update decline" do
    patch decline_url(@decline), params: { decline: {  } }
    assert_redirected_to decline_url(@decline)
  end

  test "should destroy decline" do
    assert_difference('Decline.count', -1) do
      delete decline_url(@decline)
    end

    assert_redirected_to declines_url
  end
end
