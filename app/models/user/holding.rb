class User::Holding < ApplicationRecord
  self.table_name = 'user/holdings'

  belongs_to :portfolio

  belongs_to :currency

  validates :size,
    numericality: {
      greater_than_or_equal_to: 0
    }

  delegate :user, to: :portfolio

  delegate :symbol, :name, :title, to: :currency

  def sanitized_attributes
    super.merge(
      'symbol' => symbol,
      'name' => name,
      'title' => title,
      'size' => size
    )
  end

  def to_s
    "#{size} #{currency}"
  end
end
