class Cart < ActiveRecord::Base
  has_many :line_items, dependent: :destroy

  before_create :generate_auth_token
  validates :auth_token, uniqueness: true

  def total_price
    line_items.to_a.sum(&:total_price)
  end

  private

  def generate_auth_token
    loop do
      self.auth_token = SecureRandom.hex
      break unless Cart.exists?(auth_token: auth_token)
    end
  end
end
