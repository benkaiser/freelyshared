require "test_helper"

class NeedTest < ActiveSupport::TestCase
  setup do
    @church = Church.create!(
      name: "Test Church",
      location_name: "Test City",
      latitude: -27.47,
      longitude: 153.02,
      status: "ready"
    )
    @member = @church.church_members.create!(
      name: "Test User",
      email: "test-need@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "auto-sets expiry to 30 days" do
    need = @member.needs.create!(
      title: "Need help",
      church: @church
    )
    assert_in_delta 30.days.from_now.to_i, need.expires_at.to_i, 5
  end

  test "open_needs scope excludes expired" do
    active = @member.needs.create!(title: "Active", church: @church)
    expired = @member.needs.create!(title: "Expired", church: @church, expires_at: 1.day.ago)

    results = Need.open_needs
    assert_includes results, active
    assert_not_includes results, expired
  end

  test "open_needs scope excludes fulfilled" do
    active = @member.needs.create!(title: "Active", church: @church)
    fulfilled = @member.needs.create!(title: "Fulfilled", church: @church, status: "fulfilled")

    results = Need.open_needs
    assert_includes results, active
    assert_not_includes results, fulfilled
  end

  test "fulfill and reopen" do
    need = @member.needs.create!(title: "Need help", church: @church)
    need.fulfill!
    assert_equal "fulfilled", need.status

    need.reopen!
    assert_equal "open", need.status
  end
end
