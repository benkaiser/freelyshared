class ChurchMembership < ApplicationRecord
  belongs_to :church_member
  belongs_to :church

  validates :approval_status, inclusion: { in: %w[approved pending rejected] }
  validates :church_member_id, uniqueness: { scope: :church_id, message: "is already a member of this church" }

  scope :approved, -> { where(approval_status: "approved") }
  scope :pending_approval, -> { where(approval_status: "pending") }
  scope :admins, -> { where(admin: true).approved }

  after_create :check_church_ready_on_create
  after_update :check_church_ready_on_approval, if: -> { saved_change_to_approval_status? && approved? }

  def approved?
    approval_status == "approved"
  end

  def pending?
    approval_status == "pending"
  end

  private

  def check_church_ready_on_create
    church.check_ready! if approved?
  end

  def check_church_ready_on_approval
    church.check_ready!
  end
end
