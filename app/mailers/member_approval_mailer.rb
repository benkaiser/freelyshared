class MemberApprovalMailer < ApplicationMailer
  def notify_admins(member)
    @member = member
    @church = member.church
    admin_emails = @church.admins.pluck(:email)
    return if admin_emails.empty?

    mail(
      to: admin_emails,
      subject: "New member request for #{@church.name} — #{@member.name}"
    )
  end

  def approved(member)
    @member = member
    @church = member.church
    mail(
      to: member.email,
      subject: "Welcome to #{@church.name} on FreelyShared!"
    )
  end

  def rejected(member)
    @member = member
    @church = member.church
    mail(
      to: member.email,
      subject: "Update on your request to join #{@church.name}"
    )
  end
end
