require "test_helper"

class ItemTest < ActiveSupport::TestCase
  setup do
    @church = Church.create!(
      name: "Test Church",
      location_name: "Test City",
      latitude: -27.47,
      longitude: 153.02,
      status: "ready"
    )
    @member = ChurchMember.create!(
      name: "Test User",
      email: "test-item@example.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    ChurchMembership.create!(
      church_member: @member,
      church: @church,
      approval_status: "approved",
      joined_at: Time.current
    )
  end

  test "valid item" do
    item = @member.items.build(title: "Drill", category: "Tools")
    assert item.valid?
  end

  test "requires title" do
    item = @member.items.build(category: "Tools")
    assert_not item.valid?
    assert_includes item.errors[:title], "can't be blank"
  end

  test "requires valid category" do
    item = @member.items.build(title: "X", category: "Invalid")
    assert_not item.valid?
  end

  test "defaults to available" do
    item = @member.items.create!(title: "Drill", category: "Tools")
    assert item.available?
  end

  test "defaults category to Other" do
    item = @member.items.build(title: "Thing")
    item.valid?
    assert_equal "Other", item.category
  end

  test "scopes by category" do
    @member.items.create!(title: "A", category: "Tools")
    @member.items.create!(title: "B", category: "Electronics")
    tools = @member.items.by_category("Tools")
    all = @member.items.by_category(nil)
    assert_equal 1, tools.count
    assert all.count >= 2
  end

  test "owner? returns true for owner" do
    item = @member.items.create!(title: "Drill", category: "Tools")
    assert item.owner?(@member)
  end

  test "visible_items includes items from multi-church member" do
    church2 = Church.create!(
      name: "Second Church",
      location_name: "Other City",
      latitude: -33.87,
      longitude: 151.21,
      status: "ready"
    )
    ChurchMembership.create!(
      church_member: @member,
      church: church2,
      approval_status: "approved",
      joined_at: Time.current
    )
    item = @member.items.create!(title: "Shared Drill", category: "Tools")

    # Item should be visible in both churches
    assert_includes @church.visible_items, item
    assert_includes church2.visible_items, item
  end
end
