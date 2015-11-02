class LineItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :cart
  belongs_to :order

  validates :quantity, :price, :product, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 1 }
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }

  # LineItem must belong to a Cart OR to an Order
  validates :cart_id, presence: true,
                      unless: ->(line_item) { line_item.order_id.present? }
  validates :order_id, presence: true,
                       unless: ->(line_item) { line_item.cart_id.present? }

  def total_price
    product.price * quantity
  end
end
