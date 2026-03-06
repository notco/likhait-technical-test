class Category < ApplicationRecord
  has_many :expenses, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
end
