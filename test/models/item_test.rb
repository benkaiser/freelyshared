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
    @member = @church.church_members.create!(
      name: "Test User",
      email: "test-item@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "valid item" do
    item = @member.items.build(title: "Drill", category: "Tools", church: @church)
    assert item.valid?
  end

  test "requires title" do
    item = @member.items.build(category: "Tools", church: @church)
    assert_not item.valid?
    assert_includes item.errors[:title], "can't be blank"
  end

  test "requires valid category" do
    item = @member.items.build(title: "X", category: "Invalid", church: @church)
    assert_not item.valid?
  end

  test "defaults to available" do
    item = @member.items.create!(title: "Drill", category: "Tools", church: @church)
    assert item.available?
  end

  test "defaults category to Other" do
    item = @member.items.build(title: "Thing", church: @church)
    item.valid?
    assert_equal "Other", item.category
  end

  test "scopes by category" do
    @member.items.create!(title: "A", category: "Tools", church: @church)
    @member.items.create!(title: "B", category: "Electronics", church: @church)
    tools = @member.items.by_category("Tools")
    all = @member.items.by_category(nil)
    assert_equal 1, tools.count
    assert all.count >= 2
  end

  test "owner? returns true for owner" do
    item = @member.items.create!(title: "Drill", category: "Tools", church: @church)
    assert item.owner?(@member)
  end
end
