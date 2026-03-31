require "test_helper"

class ChurchRegistrationFlowTest < ActionDispatch::IntegrationTest
  test "registering a church with 5 members auto-activates and sends emails" do
    # 1 welcome + 4 invitations + 5 church-ready notifications = 10
    assert_emails 10 do
      post churches_path, params: {
        church: {
          name: "Integration Test Church",
          location_name: "Sydney, NSW",
          latitude: -33.87,
          longitude: 151.21
        },
        registrant_name: "Alice Leader",
        registrant_email: "alice_leader_#{rand(99999)}@test.com",
        registrant_password: "password123",
        registrant_admin: "1",
        members: [
          { name: "Bob One", email: "bob1_#{rand(99999)}@test.com", admin: "0" },
          { name: "Carol Two", email: "carol2_#{rand(99999)}@test.com", admin: "0" },
          { name: "Dave Three", email: "dave3_#{rand(99999)}@test.com", admin: "0" },
          { name: "Eve Four", email: "eve4_#{rand(99999)}@test.com", admin: "0" }
        ]
      }
    end

    church = Church.find_by(name: "Integration Test Church")
    assert_not_nil church
    assert_equal "ready", church.status, "Church should auto-activate with 5 members (1 registrant + 4 initial)"
    assert_equal 5, church.member_count
    assert church.ready_at.present?
  end

  test "registering a church with fewer than 5 members stays pending" do
    post churches_path, params: {
      church: {
        name: "Small Test Church",
        location_name: "Melbourne, VIC",
        latitude: -37.81,
        longitude: 144.96
      },
      registrant_name: "Frank Solo",
      registrant_email: "frank_solo_#{rand(99999)}@test.com",
      registrant_password: "password123",
      registrant_admin: "1",
      members: [
        { name: "Grace Two", email: "grace2_#{rand(99999)}@test.com", admin: "0" }
      ]
    }

    church = Church.find_by(name: "Small Test Church")
    assert_not_nil church
    assert_equal "pending", church.status
    assert_equal 2, church.member_count
  end

  test "registrant receives welcome email with church join link" do
    assert_emails 1 do # just the welcome email (no initial members)
      post churches_path, params: {
        church: {
          name: "Welcome Email Test Church",
          location_name: "Brisbane, QLD",
          latitude: -27.47,
          longitude: 153.02
        },
        registrant_name: "Hank Registrant",
        registrant_email: "hank_reg_#{rand(99999)}@test.com",
        registrant_password: "password123",
        registrant_admin: "1"
      }
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal "Welcome to FreelyShared! Share Welcome Email Test Church's sign-up link", email.subject
  end

  test "initial members receive invitation emails with password reset links" do
    ActionMailer::Base.deliveries.clear

    post churches_path, params: {
      church: {
        name: "Invitation Test Church",
        location_name: "Perth, WA",
        latitude: -31.95,
        longitude: 115.86
      },
      registrant_name: "Ivy Inviter",
      registrant_email: "ivy_inv_#{rand(99999)}@test.com",
      registrant_password: "password123",
      registrant_admin: "1",
      members: [
        { name: "Jack Invited", email: "jack_inv_#{rand(99999)}@test.com", admin: "0" }
      ]
    }

    # Should have 1 welcome + 1 invitation = 2 emails
    assert_equal 2, ActionMailer::Base.deliveries.count

    invitation = ActionMailer::Base.deliveries.find { |e| e.subject.include?("invited") }
    assert_not_nil invitation, "Should have an invitation email"
    assert_match "Jack Invited", invitation.body.encoded
    assert_match "Set My Password", invitation.body.encoded

    # The invited member should have a reset token set
    invited = ChurchMember.find_by(name: "Jack Invited")
    assert invited.reset_password_token.present?, "Invited member should have a reset token"
  end

  test "registrant is signed in and church membership is created" do
    post churches_path, params: {
      church: {
        name: "Auth Test Church",
        location_name: "Adelaide, SA",
        latitude: -34.93,
        longitude: 138.60
      },
      registrant_name: "Kim Auth",
      registrant_email: "kim_auth_#{rand(99999)}@test.com",
      registrant_password: "password123",
      registrant_admin: "1"
    }

    church = Church.find_by(name: "Auth Test Church")
    registrant = ChurchMember.find_by(name: "Kim Auth")

    assert_not_nil registrant
    assert registrant.member_of?(church)
    assert registrant.admin_of?(church)

    membership = registrant.membership_for(church)
    assert membership.is_registrant?
    assert membership.approved?
  end
end
