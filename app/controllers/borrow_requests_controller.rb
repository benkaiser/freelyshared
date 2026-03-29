class BorrowRequestsController < ApplicationController
  before_action :authenticate_church_member!
  before_action :set_item
  before_action :set_borrow_request, only: [ :owner_confirm, :borrower_confirm, :mark_returned, :cancel ]

  def new
    @borrow_request = @item.borrow_requests.build
  end

  def create
    @borrow_request = @item.borrow_requests.build(borrow_request_params)
    @borrow_request.requester = current_church_member

    if @borrow_request.save
      BorrowRequestMailer.new_request(@borrow_request).deliver_later
      NotificationService.notify_borrow_request(@borrow_request)
      redirect_to @item, notice: "Borrow request sent! The owner will be notified."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def owner_confirm
    unless @borrow_request.item.owner?(current_church_member)
      redirect_to @item, alert: "Only the item owner can confirm."
      return
    end
    @borrow_request.confirm_by_owner!
    redirect_to @item, notice: "You confirmed the borrow request."
  end

  def borrower_confirm
    unless @borrow_request.requester == current_church_member
      redirect_to @item, alert: "Only the borrower can confirm."
      return
    end
    @borrow_request.confirm_by_borrower!
    redirect_to @item, notice: "You confirmed the borrow."
  end

  def mark_returned
    unless @borrow_request.item.owner?(current_church_member) || @borrow_request.requester == current_church_member
      redirect_to @item, alert: "Not authorized."
      return
    end
    @borrow_request.mark_returned!
    redirect_to @item, notice: "Item marked as returned."
  end

  def cancel
    unless @borrow_request.item.owner?(current_church_member) || @borrow_request.requester == current_church_member
      redirect_to @item, alert: "Not authorized."
      return
    end
    @borrow_request.cancel!
    redirect_to @item, notice: "Borrow request cancelled."
  end

  private

  def set_item
    @item = current_church.items.find(params[:item_id])
  end

  def set_borrow_request
    @borrow_request = @item.borrow_requests.find(params[:id])
  end

  def borrow_request_params
    params.require(:borrow_request).permit(:start_date, :end_date, :phone)
  end
end
