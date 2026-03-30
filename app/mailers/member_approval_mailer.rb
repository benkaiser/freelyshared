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

  # For signed-in users joining a new church
  def notify_admins_for_church(church, member)
    @member = member
    @church = church
    admin_emails = church.admins.pluck(:email)
    return if admin_emails.empty?

    mail(
      to: admin_emails,
      subject: "New member request for #{@church.name} — #{@member.name}"
    )
  end

  def approved(member)
    @member = member
    @church = member.church || member.approved_churches.last
    mail(
      to: member.email,
      subject: "Welcome to #{@church&.name || 'your church'} on FreelyShared!"
    )
  end

  def rejected(member)
    @member = member
    @church = member.church || member.churches.last
    mail(
      to: member.email,
      subject: "Update on your request to join #{@church&.name || 'a church'}"
    )
  end
end
