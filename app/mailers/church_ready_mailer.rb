class ChurchReadyMailer < ApplicationMailer
  def notify_member(church, member)
    return unless member.email_notify_church_activation

    @church = church
    @member = member
    set_unsubscribe_headers(member, "church_activation")
    mail(
      to: member.email,
      subject: "#{church.name} is now active on FreelyShared!"
    )
  end
end
