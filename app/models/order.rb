class Order < ActiveRecord::Base
  PAYMENT_TYPES = %w( Check Credit\ card Purchase\ order )
  has_many :line_items, dependent: :destroy

  validates :name, :address, :email, presence: true
  validates :pay_type, inclusion: PAYMENT_TYPES

  before_create :generate_auth_token
  validates :auth_token, uniqueness: true

  def self.create_from_cart(cart, order_params)
    order = Order.new(order_params)
    return nil, order.errors unless order.save

    order.add_line_items_from_cart(cart)
    unless order.save
      order.destroy
      return nil, order.errors
    end

    cart.reload
    cart.destroy
    order
  end

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      line_items << item
    end
  end

  private

  def generate_auth_token
    loop do
      self.auth_token = SecureRandom.hex
      break unless Cart.exists?(auth_token: auth_token)
    end
  end
end
