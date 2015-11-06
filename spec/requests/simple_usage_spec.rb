require 'rails_helper'

describe 'MiniMarket API' do
  describe 'GET /products' do
    it 'lists all the products' do
      FactoryGirl.create :product, title: 'The Lord of the Rings'
      FactoryGirl.create :product, title: 'The Two Towers'

      get '/products', {}, 'Accept' => 'application/json'

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      products_titles = body.map { |m| m['title'] }

      expect(products_titles).to match_array(['The Lord of the Rings',
                                              'The Two Towers'])
    end
  end

  describe 'POST /carts' do
    it 'creates a cart' do
      post '/carts', 'Accept' => 'application/json'

      expect(response.status).to eq 201 # created

      body = JSON.parse(response.body)
      expect(body['auth_token']).to eq Cart.first.auth_token
    end
  end

  describe 'GET /carts/:cart_id/line_items' do
    it 'lists all the line items for the cart' do
      5.times { FactoryGirl.create :product }
      cart = FactoryGirl.create :cart
      3.times do
        product = Product.all.sample
        cart.line_items.create(product_id: product.id,
                               price: product.price,
                               quantity: 1)
      end

      get "/carts/#{cart.id}/line_items",
          { 'auth_token' => cart.auth_token },
          'Accept' => 'application/json'

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      line_items_ids = body.map { |m| m['id'] }
      real_line_items_ids = cart.line_items.map(&:id)

      expect(line_items_ids.count).to eq 3
      expect(line_items_ids).to match_array(real_line_items_ids)
    end
  end

  describe 'POST /carts/:cart_id/line_items' do
    it 'creates a line item for the cart' do
      5.times { FactoryGirl.create :product }
      cart = FactoryGirl.create :cart

      product = Product.all.sample
      line_item_params = {
        'line_item' => {
          'product_id' => product.id,
          'price' => product.price,
          'quantity' => 1
        },
        'auth_token' => cart.auth_token
      }.to_json

      request_headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }

      post "/carts/#{cart.id}/line_items", line_item_params, request_headers

      expect(response.status).to eq 201 # created

      body = JSON.parse(response.body)
      line_item = LineItem.find(body['id'])

      expect(cart.line_items).to match_array([line_item])
      expect(line_item.product_id).to eq product.id
      expect(line_item.price).to eq product.price
      expect(line_item.quantity).to eq 1
    end
  end
end
