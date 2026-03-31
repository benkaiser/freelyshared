require "test_helper"

class EmailNotificationFlowTest < ActionDispatch::IntegrationTest
  setup do
    @church = Church.create!(
      name: "Email Test Church",
      location_name: "Test City",
      latitude: -27.47,
      longitude: 153.02,
      status: "ready"
    )

    @poster = ChurchMember.create!(
      name: "Need Poster",
      email: "poster_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
    @church.church_memberships.create!(
      church_member: @poster,
      approval_status: "approved",
      joined_at: Time.current
    )

    @recipient = ChurchMember.create!(
      name: "Email Recipient",
      email: "recipient_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church,
      email_notify_new_needs: true
    )
    @church.church_memberships.create!(
      church_member: @recipient,
      approval_status: "approved",
      joined_at: Time.current
    )

    @opted_out = ChurchMember.create!(
      name: "Opted Out User",
      email: "optedout_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church,
      email_notify_new_needs: false
    )
    @church.church_memberships.create!(
      church_member: @opted_out,
      approval_status: "approved",
      joined_at: Time.current
    )

    ActionMailer::Base.deliveries.clear
  end

  test "posting a need sends email to opted-in members but not poster" do
    need = @poster.needs.create!(title: "Need a ride", description: "To church on Sunday")

    NotificationService.email_notify_new_need(need)

    assert_equal 1, ActionMailer::Base.deliveries.count
    email = ActionMailer::Base.deliveries.first
    assert_equal [@recipient.email], email.to
    assert_match "Need a ride", email.subject
    assert_match "Need Poster", email.body.encoded
  end

  test "opted-out member does not receive need email" do
    need = @poster.needs.create!(title: "Need help", description: "Moving house")

    NotificationService.email_notify_new_need(need)

    recipients = ActionMailer::Base.deliveries.map(&:to).flatten
    assert_not_includes recipients, @opted_out.email
  end

  test "poster does not receive their own need email" do
    need = @poster.needs.create!(title: "My need", description: "Test")

    NotificationService.email_notify_new_need(need)

    recipients = ActionMailer::Base.deliveries.map(&:to).flatten
    assert_not_includes recipients, @poster.email
  end

  test "rate limit: second need within 24h for same church sends no emails" do
    need1 = @poster.needs.create!(title: "First need")
    NotificationService.email_notify_new_need(need1)

    first_count = ActionMailer::Base.deliveries.count
    assert first_count > 0

    need2 = @poster.needs.create!(title: "Second need")
    NotificationService.email_notify_new_need(need2)

    assert_equal first_count, ActionMailer::Base.deliveries.count, "No additional emails should be sent within 24h"
  end

  test "rate limit: need in different church sends emails" do
    church2 = Church.create!(
      name: "Second Email Church",
      location_name: "Other City",
      latitude: -33.87,
      longitude: 151.21,
      status: "ready"
    )
    church2.church_memberships.create!(
      church_member: @poster,
      approval_status: "approved",
      joined_at: Time.current
    )
    member2 = ChurchMember.create!(
      name: "Church2 Member",
      email: "church2member_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: church2,
      email_notify_new_needs: true
    )
    church2.church_memberships.create!(
      church_member: member2,
      approval_status: "approved",
      joined_at: Time.current
    )

    # First need triggers emails for both churches
    need = @poster.needs.create!(title: "Cross-church need")
    NotificationService.email_notify_new_need(need)

    recipients = ActionMailer::Base.deliveries.map(&:to).flatten
    assert_includes recipients, @recipient.email
    assert_includes recipients, member2.email
  end

  test "rate limit resets after 24 hours" do
    @church.update_column(:last_need_email_sent_at, 25.hours.ago)

    need = @poster.needs.create!(title: "Need after 24h")
    NotificationService.email_notify_new_need(need)

    assert ActionMailer::Base.deliveries.count > 0
  end

  test "need email contains unsubscribe link" do
    need = @poster.needs.create!(title: "Unsub test need")
    NotificationService.email_notify_new_need(need)

    email = ActionMailer::Base.deliveries.first
    assert_match "Unsubscribe", email.body.encoded
    assert_match "email_unsubscribe", email.body.encoded
  end

  test "need email has List-Unsubscribe header" do
    need = @poster.needs.create!(title: "Header test need")
    NotificationService.email_notify_new_need(need)

    email = ActionMailer::Base.deliveries.first
    assert email.header["List-Unsubscribe"].present?
    assert email.header["List-Unsubscribe-Post"].present?
  end
end

class UnsubscribeTokenTest < ActiveSupport::TestCase
  setup do
    @church = Church.create!(
      name: "Token Test Church",
      location_name: "Test",
      latitude: -27.47,
      longitude: 153.02,
      status: "ready"
    )
    @member = ChurchMember.create!(
      name: "Token User",
      email: "token_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church
    )
  end

  test "unsubscribe token round-trip" do
    token = @member.email_unsubscribe_token("new_needs")
    found = ChurchMember.find_by_unsubscribe_token(token, "new_needs")
    assert_equal @member, found
  end

  test "token with wrong category returns nil" do
    token = @member.email_unsubscribe_token("new_needs")
    found = ChurchMember.find_by_unsubscribe_token(token, "church_activation")
    assert_nil found
  end

  test "invalid token returns nil" do
    found = ChurchMember.find_by_unsubscribe_token("invalid-token", "new_needs")
    assert_nil found
  end
end

class UnsubscribeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @church = Church.create!(
      name: "Unsub Controller Church",
      location_name: "Test",
      latitude: -27.47,
      longitude: 153.02,
      status: "ready"
    )
    @member = ChurchMember.create!(
      name: "Unsub User",
      email: "unsub_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church,
      email_notify_new_needs: true
    )
  end

  test "GET show with valid token renders confirmation page" do
    token = @member.email_unsubscribe_token("new_needs")
    get email_unsubscribe_path(token: token, category: "new_needs")
    assert_response :success
    assert_match "Unsubscribe", response.body
  end

  test "PATCH update disables the preference" do
    token = @member.email_unsubscribe_token("new_needs")
    patch email_unsubscribe_path, params: { token: token, category: "new_needs" }
    assert_response :success

    @member.reload
    assert_not @member.email_notify_new_needs
  end

  test "PATCH update with category=all disables all preferences" do
    token = @member.email_unsubscribe_token("all")
    patch email_unsubscribe_path, params: { token: token, category: "all" }
    assert_response :success

    @member.reload
    assert_not @member.email_notify_new_needs
    assert_not @member.email_notify_new_items
    assert_not @member.email_notify_new_services
    assert_not @member.email_notify_church_activation
  end

  test "GET show with expired token shows error" do
    get email_unsubscribe_path(token: "bad-token", category: "new_needs")
    assert_response :success
    assert_match "expired", response.body
  end
end

class ChurchReadyEmailPreferenceTest < ActiveSupport::TestCase
  setup do
    @church = Church.create!(
      name: "Ready Pref Church",
      location_name: "Test",
      latitude: -27.47,
      longitude: 153.02,
      status: "pending"
    )
  end

  test "church ready email respects email_notify_church_activation preference" do
    opted_in = ChurchMember.create!(
      name: "Opted In",
      email: "optedin_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church,
      email_notify_church_activation: true
    )
    opted_out = ChurchMember.create!(
      name: "Opted Out",
      email: "optedout2_#{rand(99999)}@test.com",
      password: "password123",
      password_confirmation: "password123",
      church: @church,
      email_notify_church_activation: false
    )

    ActionMailer::Base.deliveries.clear

    # Manually call the mailer for both
    ChurchReadyMailer.notify_member(@church, opted_in).deliver_now
    ChurchReadyMailer.notify_member(@church, opted_out)&.deliver_now

    recipients = ActionMailer::Base.deliveries.map(&:to).flatten
    assert_includes recipients, opted_in.email
    assert_not_includes recipients, opted_out.email
  end
end
