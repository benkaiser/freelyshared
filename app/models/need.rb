class Need < ApplicationRecord
  STATUSES = %w[open fulfilled].freeze

  belongs_to :church_member
  belongs_to :church, optional: true

  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :open_needs, -> { where(status: "open").where("expires_at > ?", Time.current) }
  scope :for_church, ->(church) { where(church: church) }
  scope :not_expired, -> { where("expires_at > ?", Time.current) }

  before_validation :set_expiry, on: :create

  def expired?
    expires_at < Time.current
  end

  def owner?(member)
    church_member_id == member.id
  end

  def fulfill!
    update!(status: "fulfilled")
  end

  def reopen!
    update!(status: "open")
  end

  private

  def set_expiry
    self.expires_at ||= 30.days.from_now
  end
end
