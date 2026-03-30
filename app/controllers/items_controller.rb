class ItemsController < ApplicationController
  before_action :authenticate_church_member!
  before_action :set_item, only: [ :show, :edit, :update, :destroy, :toggle_availability ]
  before_action :authorize_owner!, only: [ :edit, :update, :toggle_availability ]
  before_action :authorize_owner_or_admin!, only: [ :destroy ]

  def index
    @items = current_church.visible_items.includes(:church_member, photo_attachment: :blob)
      .by_category(params[:category])
      .order(created_at: :desc)
    @categories = Item::CATEGORIES
  end

  def show
    @borrow_request = BorrowRequest.new
  end

  def new
    @item = current_church_member.items.build
  end

  def create
    @item = current_church_member.items.build(item_params)

    if @item.save
      redirect_to @item, notice: "Item listed successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @item, notice: "Item updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless @item.owner?(current_church_member)
      ModerationAction.create!(
        actor: current_church_member,
        action_type: "remove_item",
        target_type: "Item",
        target_id: @item.id,
        church: current_church
      )
    end
    @item.destroy
    redirect_to items_path, notice: "Item removed."
  end

  def toggle_availability
    @item.update!(available: !@item.available)
    redirect_to @item, notice: "Availability updated."
  end

  private

  def set_item
    @item = current_church.visible_items.find(params[:id])
  end

  def authorize_owner!
    unless @item.owner?(current_church_member)
      redirect_to items_path, alert: "You can only edit your own items."
    end
  end

  def authorize_owner_or_admin!
    unless @item.owner?(current_church_member) || current_church_member&.admin_of?(current_church)
      redirect_to items_path, alert: "You don't have permission to do that."
    end
  end

  def item_params
    params.require(:item).permit(:title, :description, :category, :photo)
  end
end
