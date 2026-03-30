class Item < ApplicationRecord
  include HasPhoto

  CATEGORIES = [
    "Tools",
    "Kitchen & Home",
    "Garden & Outdoor",
    "Books & Media",
    "Sports & Recreation",
    "Kids & Family",
    "Electronics",
    "Transport",
    "Other"
  ].freeze

  belongs_to :church_member
  belongs_to :church
  has_many :borrow_requests, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  scope :available, -> { where(available: true) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :for_church, ->(church) { where(church: church) }

  before_validation :set_default_category

  def owner?(member)
    church_member_id == member.id
  end

  private

  def set_default_category
    self.category = "Other" if category.blank?
  end
end
