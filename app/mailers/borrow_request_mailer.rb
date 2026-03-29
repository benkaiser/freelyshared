class BorrowRequestMailer < ApplicationMailer
  def new_request(borrow_request)
    @borrow_request = borrow_request
    @item = borrow_request.item
    @owner = @item.church_member
    @requester = borrow_request.requester

    mail(
      to: @owner.email,
      subject: "Someone wants to borrow your #{@item.title}"
    )
  end
end
