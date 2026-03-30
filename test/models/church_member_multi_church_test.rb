require "test_helper"

class ChurchMemberMultiChurchTest < ActiveSupport::TestCase
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
      name: "Multi User",
      email: "multi-member@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    @membership = ChurchMembership.create!(
      church_member: @member,
      church: @church,
      admin: true,
      approval_status: "approved",
      joined_at: Time.current
    )
  end

  test "member_of? returns true for approved membership" do
    assert @member.member_of?(@church)
  end

  test "member_of? returns false without membership" do
    assert_not @member.member_of?(@church2)
  end

  test "member_of? returns false for pending membership" do
    ChurchMembership.create!(
      church_member: @member,
      church: @church2,
      approval_status: "pending"
    )
    assert_not @member.member_of?(@church2)
  end

  test "admin_of? returns true for admin membership" do
    assert @member.admin_of?(@church)
  end

  test "admin_of? returns false for non-admin membership" do
    ChurchMembership.create!(
      church_member: @member,
      church: @church2,
      admin: false,
      approval_status: "approved"
    )
    assert_not @member.admin_of?(@church2)
  end

  test "approved_churches returns only approved churches" do
    ChurchMembership.create!(
      church_member: @member,
      church: @church2,
      approval_status: "pending"
    )
    approved = @member.approved_churches
    assert_includes approved, @church
    assert_not_includes approved, @church2
  end

  test "approved_churches returns multiple approved churches" do
    ChurchMembership.create!(
      church_member: @member,
      church: @church2,
      approval_status: "approved"
    )
    approved = @member.approved_churches
    assert_includes approved, @church
    assert_includes approved, @church2
    assert_equal 2, approved.count
  end

  test "active_for_authentication? with approved membership" do
    assert @member.active_for_authentication?
  end

  test "active_for_authentication? returns false when suspended" do
    @member.update!(suspended: true)
    assert_not @member.active_for_authentication?
  end

  test "active_for_authentication? with only pending memberships" do
    @membership.update!(approval_status: "pending")
    @member.update!(approval_status: "pending")
    assert_not @member.active_for_authentication?
  end

  test "membership_for returns the membership for a given church" do
    assert_equal @membership, @member.membership_for(@church)
    assert_nil @member.membership_for(@church2)
  end
end
