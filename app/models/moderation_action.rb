class ModerationAction < ApplicationRecord
  belongs_to :actor, class_name: "ChurchMember"
  belongs_to :church, optional: true

  validates :action_type, :target_type, :target_id, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_church, ->(church) { where(church: church) }
  scope :by_type, ->(type) { where(action_type: type) if type.present? }

  ACTION_TYPES = %w[
    remove_item remove_service remove_need remove_borrow_request
    suspend_user unsuspend_user delete_user
    activate_church archive_church
    promote_admin demote_admin
    approve_member reject_member
  ].freeze

  def target
    target_type.constantize.find_by(id: target_id)
  end

  def target_label
    case target_type
    when "Item" then "Item ##{target_id}"
    when "ServicesListing" then "Service ##{target_id}"
    when "Need" then "Need ##{target_id}"
    when "BorrowRequest" then "Borrow Request ##{target_id}"
    when "ChurchMember" then "Member ##{target_id}"
    when "Church" then "Church ##{target_id}"
    else "#{target_type} ##{target_id}"
    end
  end
end
