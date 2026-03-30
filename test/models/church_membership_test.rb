require "test_helper"

class ChurchMembershipTest < ActiveSupport::TestCase
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
      name: "Test User",
      email: "membership-test@example.com",
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

  test "validates uniqueness of church_member per church" do
    duplicate = ChurchMembership.new(
      church_member: @member,
      church: @church,
      approval_status: "approved"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:church_member_id], "is already a member of this church"
  end

  test "validates approval_status inclusion" do
    membership = ChurchMembership.new(
      church_member: @member,
      church: @church2,
      approval_status: "invalid"
    )
    assert_not membership.valid?
    assert_includes membership.errors[:approval_status], "is not included in the list"
  end

  test "approved scope returns only approved memberships" do
    pending_membership = ChurchMembership.create!(
      church_member: @member,
      church: @church2,
      approval_status: "pending"
    )
    approved = ChurchMembership.approved
    assert_includes approved, @membership
    assert_not_includes approved, pending_membership
  end

  test "pending_approval scope returns only pending memberships" do
    pending_membership = ChurchMembership.create!(
      church_member: @member,
      church: @church2,
      approval_status: "pending"
    )
    pending = ChurchMembership.pending_approval
    assert_includes pending, pending_membership
    assert_not_includes pending, @membership
  end

  test "admins scope returns approved admin memberships" do
    non_admin = ChurchMember.create!(
      name: "Non Admin",
      email: "nonadmin-test@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    non_admin_membership = ChurchMembership.create!(
      church_member: non_admin,
      church: @church,
      admin: false,
      approval_status: "approved"
    )
    admins = @church.church_memberships.admins
    assert_includes admins, @membership
    assert_not_includes admins, non_admin_membership
  end

  test "approved? and pending? helpers work" do
    assert @membership.approved?
    assert_not @membership.pending?

    pending = ChurchMembership.create!(
      church_member: @member,
      church: @church2,
      approval_status: "pending"
    )
    assert pending.pending?
    assert_not pending.approved?
  end
end
