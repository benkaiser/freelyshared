require "test_helper"

class BorrowRequestTest < ActiveSupport::TestCase
  setup do
    @church = Church.create!(
      name: "Test Church",
      location_name: "Test City",
      latitude: -27.47,
      longitude: 153.02,
      status: "ready"
    )
    @owner = @church.church_members.create!(
      name: "Owner",
      email: "owner-br@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @borrower = @church.church_members.create!(
      name: "Borrower",
      email: "borrower-br@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @item = @owner.items.create!(
      title: "Drill",
      category: "Tools",
      church: @church
    )
  end

  test "valid borrow request" do
    request = @item.borrow_requests.build(
      requester: @borrower,
      start_date: Date.today + 1,
      end_date: Date.today + 7,
      phone: "0412345678"
    )
    assert request.valid?
  end

  test "end date must be after start date" do
    request = @item.borrow_requests.build(
      requester: @borrower,
      start_date: Date.today + 7,
      end_date: Date.today + 1,
      phone: "0412345678"
    )
    assert_not request.valid?
    assert_includes request.errors[:end_date], "must be after start date"
  end

  test "dual confirmation flow" do
    request = @item.borrow_requests.create!(
      requester: @borrower,
      start_date: Date.today + 1,
      end_date: Date.today + 7,
      phone: "0412345678"
    )

    assert_equal "pending", request.status
    assert @item.reload.available?

    request.confirm_by_owner!
    assert request.owner_confirmed?
    assert_equal "pending", request.status
    assert @item.reload.available?

    request.confirm_by_borrower!
    assert request.borrower_confirmed?
    assert_equal "confirmed", request.status
    assert_not @item.reload.available?
  end

  test "mark returned makes item available" do
    request = @item.borrow_requests.create!(
      requester: @borrower,
      start_date: Date.today + 1,
      end_date: Date.today + 7,
      phone: "0412345678"
    )
    request.confirm_by_owner!
    request.confirm_by_borrower!
    assert_not @item.reload.available?

    request.mark_returned!
    assert_equal "returned", request.status
    assert @item.reload.available?
  end

  test "cancel restores availability" do
    request = @item.borrow_requests.create!(
      requester: @borrower,
      start_date: Date.today + 1,
      end_date: Date.today + 7,
      phone: "0412345678"
    )
    request.confirm_by_owner!
    request.confirm_by_borrower!

    request.cancel!
    assert_equal "cancelled", request.status
    assert @item.reload.available?
  end
end
