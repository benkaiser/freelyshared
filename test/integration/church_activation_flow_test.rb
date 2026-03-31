require "test_helper"

class ChurchActivationFlowTest < ActionDispatch::IntegrationTest
  setup do
    @church = Church.create!(
      name: "Activation Flow Church",
      location_name: "Test City",
      latitude: -27.47,
      longitude: 153.02,
      status: "pending"
    )
  end

  test "church activates when 5th approved membership is created" do
    members = 4.times.map do |i|
      m = ChurchMember.create!(
        name: "Member #{i}",
        email: "actflow_#{i}_#{rand(99999)}@test.com",
        password: "password123",
        password_confirmation: "password123",
        church: @church
      )
      @church.church_memberships.create!(
        church_member: m,
        approval_status: "approved",
        joined_at: Time.current
      )
      m
    end

    assert_equal "pending", @church.reload.status
    assert_equal 4, @church.member_count

    # 5th member triggers activation
    fifth = ChurchMember.create!(
      name: "Fifth Member",
      email: "actflow_5th_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    @church.church_memberships.create!(
      church_member: fifth,
      approval_status: "approved",
      joined_at: Time.current
    )

    assert_equal "ready", @church.reload.status
    assert @church.ready_at.present?
  end

  test "church activates when pending membership is approved as 5th member" do
    4.times do |i|
      m = ChurchMember.create!(
        name: "Approved #{i}",
        email: "actapprove_#{i}_#{rand(99999)}@test.com",
        password: "password123",
        password_confirmation: "password123",
        church: @church
      )
      @church.church_memberships.create!(
        church_member: m,
        approval_status: "approved",
        joined_at: Time.current
      )
    end

    # 5th member starts as pending
    pending_member = ChurchMember.create!(
      name: "Pending Fifth",
      email: "actpend_5th_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    pending_membership = @church.church_memberships.create!(
      church_member: pending_member,
      approval_status: "pending",
      joined_at: Time.current
    )

    assert_equal "pending", @church.reload.status
    assert_equal 4, @church.member_count

    # Approving the 5th member triggers activation
    pending_membership.update!(approval_status: "approved")

    assert_equal "ready", @church.reload.status
    assert_equal 5, @church.member_count
  end

  test "activation sends notification emails to all approved members" do
    members = 4.times.map do |i|
      m = ChurchMember.create!(
        name: "Notify #{i}",
        email: "actnotify_#{i}_#{rand(99999)}@test.com",
        password: "password123",
        password_confirmation: "password123",
        church: @church
      )
      @church.church_memberships.create!(
        church_member: m,
        approval_status: "approved",
        joined_at: Time.current
      )
      m
    end

    # 5th member triggers activation and emails
    fifth = ChurchMember.create!(
      name: "Notify Fifth",
      email: "actnotify_5th_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )

    assert_emails 5 do # one ChurchReadyMailer per approved member
      @church.church_memberships.create!(
        church_member: fifth,
        approval_status: "approved",
        joined_at: Time.current
      )
    end

    assert_equal "ready", @church.reload.status
  end

  test "pending members do not count toward activation threshold" do
    4.times do |i|
      m = ChurchMember.create!(
        name: "Count #{i}",
        email: "actcount_#{i}_#{rand(99999)}@test.com",
        password: "password123",
        password_confirmation: "password123",
        church: @church
      )
      @church.church_memberships.create!(
        church_member: m,
        approval_status: "approved",
        joined_at: Time.current
      )
    end

    # Add a 5th as pending — should NOT activate
    pending = ChurchMember.create!(
      name: "Pending Count",
      email: "actcount_pend_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    @church.church_memberships.create!(
      church_member: pending,
      approval_status: "pending",
      joined_at: Time.current
    )

    assert_equal "pending", @church.reload.status
    assert_equal 4, @church.member_count
  end
end
