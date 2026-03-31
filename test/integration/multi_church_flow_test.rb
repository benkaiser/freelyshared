require "test_helper"

class MultiChurchFlowTest < ActionDispatch::IntegrationTest
  setup do
    @church1 = Church.create!(
      name: "First Church",
      location_name: "City A",
      latitude: -27.47,
      longitude: 153.02,
      status: "ready"
    )
    @church2 = Church.create!(
      name: "Second Church",
      location_name: "City B",
      latitude: -33.87,
      longitude: 151.21,
      status: "ready"
    )
    @member = ChurchMember.create!(
      name: "Multi Member",
      email: "multi_flow_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church1
    )
    @church1.church_memberships.create!(
      church_member: @member,
      approval_status: "approved",
      admin: true,
      joined_at: Time.current
    )
  end

  test "member items visible in all approved churches" do
    item = @member.items.create!(title: "Shared Drill", category: "Tools")

    # Visible in church1
    assert_includes @church1.visible_items, item

    # Not visible in church2 yet
    assert_not_includes @church2.visible_items, item

    # Join church2
    @church2.church_memberships.create!(
      church_member: @member,
      approval_status: "approved",
      joined_at: Time.current
    )

    # Now visible in both
    assert_includes @church1.visible_items, item
    assert_includes @church2.visible_items, item
  end

  test "member directories are different per church" do
    other_member = ChurchMember.create!(
      name: "Church2 Only",
      email: "church2only_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church2
    )
    @church2.church_memberships.create!(
      church_member: other_member,
      approval_status: "approved",
      joined_at: Time.current
    )

    assert_includes @church1.approved_members, @member
    assert_not_includes @church1.approved_members, other_member

    assert_includes @church2.approved_members, other_member
    assert_not_includes @church2.approved_members, @member
  end

  test "leaving last church signs user out concept" do
    membership = @member.church_memberships.first
    remaining = @member.church_memberships.approved.where.not(id: membership.id)

    assert_equal 0, remaining.count, "Should have no remaining memberships after leaving only church"
  end

  test "admin status is per-church" do
    @church2.church_memberships.create!(
      church_member: @member,
      approval_status: "approved",
      admin: false,
      joined_at: Time.current
    )

    assert @member.admin_of?(@church1)
    assert_not @member.admin_of?(@church2)
  end

  test "joining a church with admin approval creates pending membership" do
    @church2.update!(require_admin_approval: true)

    @church2.church_memberships.create!(
      church_member: @member,
      approval_status: "pending",
      joined_at: Time.current
    )

    assert_not @member.member_of?(@church2), "Pending membership should not count as member"
    assert_not_includes @church2.approved_members, @member
  end
end
