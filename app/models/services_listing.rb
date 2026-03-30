class ServicesListing < ApplicationRecord
  belongs_to :church_member
  belongs_to :church, optional: true

  validates :title, presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }

  scope :for_church, ->(church) { where(church: church) }

  def owner?(member)
    church_member_id == member.id
  end
end
