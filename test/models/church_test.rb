require "test_helper"

class ChurchTest < ActiveSupport::TestCase
  setup do
    @church = Church.create!(
      name: "Test Church",
      location_name: "Test City",
      latitude: -27.47,
      longitude: 153.02,
      status: "ready"
    )
    @church2 = Church.create!(
      name: "Second Church",
      location_name: "Other City",
      latitude: -33.87,
      longitude: 151.21,
      status: "ready"
    )
    @member = ChurchMember.create!(
      name: "Multi-Church User",
      email: "multi-church@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    @membership1 = ChurchMembership.create!(
      church_member: @member,
      church: @church,
      admin: false,
      approval_status: "approved",
      joined_at: Time.current
    )
    @membership2 = ChurchMembership.create!(
      church_member: @member,
      church: @church2,
      admin: false,
      approval_status: "approved",
      joined_at: Time.current
    )
  end

  test "visible_items returns items from approved members" do
    item = @member.items.create!(title: "Drill", category: "Tools")
    assert_includes @church.visible_items, item
    assert_includes @church2.visible_items, item
  end

  test "visible_items excludes items from non-approved members" do
    pending_member = ChurchMember.create!(
      name: "Pending User",
      email: "pending-visible@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    ChurchMembership.create!(
      church_member: pending_member,
      church: @church,
      approval_status: "pending"
    )
    item = pending_member.items.create!(title: "Saw", category: "Tools")
    assert_not_includes @church.visible_items, item
  end

  test "visible_needs returns needs from approved members" do
    need = @member.needs.create!(title: "Need a ride", church: @church)
    assert_includes @church.visible_needs, need
    assert_includes @church2.visible_needs, need
  end

  test "visible_services_listings returns services from approved members" do
    service = @member.services_listings.create!(title: "Tutoring", church: @church)
    assert_includes @church.visible_services_listings, service
    assert_includes @church2.visible_services_listings, service
  end

  test "approved_members returns only members with approved memberships" do
    other_member = ChurchMember.create!(
      name: "Other User",
      email: "other-approved@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    ChurchMembership.create!(
      church_member: other_member,
      church: @church,
      approval_status: "pending"
    )
    assert_includes @church.approved_members, @member
    assert_not_includes @church.approved_members, other_member
  end

  test "member_count counts approved memberships" do
    assert_equal 1, @church.member_count
    assert_equal 1, @church2.member_count
  end

  test "admins returns members with admin memberships" do
    @membership1.update!(admin: true)
    assert_includes @church.admins, @member
    assert_not_includes @church2.admins, @member
  end
end
