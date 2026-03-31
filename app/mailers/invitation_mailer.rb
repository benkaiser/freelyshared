class InvitationMailer < ApplicationMailer
  include Devise::Controllers::UrlHelpers

  def invite_member(member, church, invited_by:)
    @member = member
    @church = church
    @invited_by = invited_by

    # Generate a password reset token so they can set their own password
    raw_token, enc_token = Devise.token_generator.generate(ChurchMember, :reset_password_token)
    @member.update_columns(
      reset_password_token: enc_token,
      reset_password_sent_at: Time.current
    )
    @reset_url = edit_church_member_password_url(reset_password_token: raw_token)

    mail(
      to: @member.email,
      subject: "You've been invited to #{@church.name} on FreelyShared"
    )
  end
end
