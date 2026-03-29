require "test_helper"

class SignupsControllerTest < ActionDispatch::IntegrationTest
  test "should get interest" do
    get signups_interest_url
    assert_response :success
  end

  test "should get create" do
    get signups_create_url
    assert_response :success
  end

  test "should get thankyou" do
    get signups_thankyou_url
    assert_response :success
  end
end
