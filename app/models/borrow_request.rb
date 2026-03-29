class BorrowRequest < ApplicationRecord
  STATUSES = %w[pending confirmed returned cancelled].freeze

  belongs_to :item
  belongs_to :requester, class_name: "ChurchMember"

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :phone, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validate :end_date_after_start_date

  scope :pending, -> { where(status: "pending") }
  scope :confirmed, -> { where(status: "confirmed") }
  scope :active, -> { where(status: %w[pending confirmed]) }

  def owner
    item.church_member
  end

  def confirm_by_owner!
    update!(owner_confirmed: true)
    check_fully_confirmed!
  end

  def confirm_by_borrower!
    update!(borrower_confirmed: true)
    check_fully_confirmed!
  end

  def mark_returned!
    update!(status: "returned")
    item.update!(available: true)
  end

  def cancel!
    update!(status: "cancelled")
    # If this was the confirmed request, make item available again
    item.update!(available: true) if was_confirmed?
  end

  def fully_confirmed?
    owner_confirmed? && borrower_confirmed?
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date
    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def check_fully_confirmed!
    if fully_confirmed? && status == "pending"
      update!(status: "confirmed")
      item.update!(available: false)
    end
  end

  def was_confirmed?
    status_previously_was == "confirmed" || (owner_confirmed? && borrower_confirmed?)
  end
end
