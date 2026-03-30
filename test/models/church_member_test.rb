require "test_helper"

class ChurchMemberTest < ActiveSupport::TestCase
  setup do
    @church = Church.create!(
      name: "Test Church",
      location_name: "Test City",
      latitude: -27.47,
      longitude: 153.02,
      status: "ready"
    )
    @admin = ChurchMember.create!(
      name: "Admin User",
      email: "admin-test@example.com",
      password: "password123",
      password_confirmation: "password123",
      admin: true,
      church: @church
    )
    @admin_membership = ChurchMembership.create!(
      church_member: @admin,
      church: @church,
      admin: true,
      approval_status: "approved",
      joined_at: Time.current
    )
  end

  test "defaults to non-admin and approved" do
    member = ChurchMember.create!(
      name: "Regular User",
      email: "regular-test@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    assert_not member.admin?
    assert member.approved?
    assert_equal "approved", member.approval_status
  end

  test "admin scope returns only admins" do
    ChurchMember.create!(
      name: "Regular User",
      email: "regular-test@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    admins = ChurchMember.admins
    assert_includes admins, @admin
  end

  test "approved scope returns only approved members" do
    pending = ChurchMember.create!(
      name: "Pending User",
      email: "pending-test@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church,
      approval_status: "pending"
    )
    approved = ChurchMember.approved
    assert_includes approved, @admin
    assert_not_includes approved, pending
  end

  test "pending_approval scope returns only pending members" do
    pending = ChurchMember.create!(
      name: "Pending User",
      email: "pending-test@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church,
      approval_status: "pending"
    )
    assert_includes ChurchMember.pending_approval, pending
    assert_not_includes ChurchMember.pending_approval, @admin
  end

  test "active_for_authentication? returns false for pending member with no approved memberships" do
    pending = ChurchMember.create!(
      name: "Pending User",
      email: "pending-test@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church,
      approval_status: "pending"
    )
    ChurchMembership.create!(
      church_member: pending,
      church: @church,
      approval_status: "pending"
    )
    assert_not pending.active_for_authentication?
  end

  test "active_for_authentication? returns true for member with approved membership" do
    assert @admin.active_for_authentication?
  end

  test "inactive_message returns :pending_approval for pending member" do
    pending = ChurchMember.create!(
      name: "Pending User",
      email: "pending-test@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church,
      approval_status: "pending"
    )
    assert_equal :pending_approval, pending.inactive_message
  end

  test "church member_count only counts approved memberships" do
    pending_member = ChurchMember.create!(
      name: "Pending User",
      email: "pending-test@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    ChurchMembership.create!(
      church_member: pending_member,
      church: @church,
      approval_status: "pending"
    )
    # Only @admin should be counted
    assert_equal 1, @church.member_count
  end

  test "church admins returns approved admin members" do
    assert_includes @church.admins, @admin
    assert_equal 1, @church.admins.count
  end

  test "validates approval_status inclusion" do
    member = ChurchMember.new(
      name: "Bad Status",
      email: "bad-status@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church,
      approval_status: "invalid"
    )
    assert_not member.valid?
    assert_includes member.errors[:approval_status], "is not included in the list"
  end
end
