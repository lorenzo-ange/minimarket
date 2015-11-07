require 'rails_helper'

describe 'Cart API' do
  describe 'POST /carts' do
    it 'creates a cart' do
      post '/carts', 'Accept' => 'application/json'

      expect(response.status).to eq 201 # created

      body = JSON.parse(response.body)
      expect(body['auth_token']).to eq Cart.first.auth_token
    end
  end

  describe 'DELETE /carts/:cart_id' do
    before do
      5.times { FactoryGirl.create :product }
      @cart = FactoryGirl.create :cart
      3.times do
        product = Product.all.sample
        @cart.line_items.create(product_id: product.id,
                                price: product.price,
                                quantity: rand(1..6))
      end
    end

    it 'destroys a cart' do
      expect(Cart.count).to eq 1
      expect(LineItem.count).to eq 3

      delete "/carts/#{@cart.id}",
             { 'auth_token' => @cart.auth_token },
             'Accept' => 'application/json'

      expect(response.status).to eq 204

      expect(Cart.count).to eq 0
      expect(LineItem.count).to eq 0
    end
  end

  describe 'GET /carts/:cart_id/line_items' do
    before do
      5.times { FactoryGirl.create :product }
      @cart = FactoryGirl.create :cart
      3.times do
        product = Product.all.sample
        @cart.line_items.create(product_id: product.id,
                                price: product.price,
                                quantity: rand(1..6))
      end
    end

    it 'lists all the line items for the cart' do
      get "/carts/#{@cart.id}/line_items",
          { 'auth_token' => @cart.auth_token },
          'Accept' => 'application/json'

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      line_items_ids = body.map { |m| m['id'] }
      real_line_items_ids = @cart.line_items.map(&:id)

      expect(line_items_ids.count).to eq 3
      expect(line_items_ids).to match_array(real_line_items_ids)
    end
  end

  describe 'POST /carts/:cart_id/line_items' do
    before do
      5.times { FactoryGirl.create :product }
      @cart = FactoryGirl.create :cart
    end

    it 'creates a line item for the cart' do
      product = Product.all.sample
      line_item_params = {
        'line_item' => {
          'product_id' => product.id,
          'price' => product.price,
          'quantity' => 1
        },
        'auth_token' => @cart.auth_token
      }.to_json

      request_headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }

      post "/carts/#{@cart.id}/line_items", line_item_params, request_headers

      expect(response.status).to eq 201 # created

      body = JSON.parse(response.body)
      line_item = LineItem.find(body['id'])

      expect(@cart.line_items).to match_array([line_item])
      expect(line_item.product_id).to eq product.id
      expect(line_item.price).to eq product.price
      expect(line_item.quantity).to eq 1
    end
  end

  describe 'DELETE /carts/:cart_id/line_items/:line_item_id' do
    before do
      5.times { FactoryGirl.create :product }
      @cart = FactoryGirl.create :cart
      3.times do
        product = Product.all.sample
        @cart.line_items.create(product_id: product.id,
                                price: product.price,
                                quantity: rand(1..6))
      end
    end

    it 'destroys a line item' do
      expect(@cart.line_items.count).to eq 3

      line_item = @cart.line_items.sample
      delete "/carts/#{@cart.id}/line_items/#{line_item.id}",
             { 'auth_token' => @cart.auth_token },
             'Accept' => 'application/json'

      expect(response.status).to eq 204

      @cart.reload
      expect(@cart.line_items.count).to eq 2
      expect(@cart.line_items).not_to include(line_item)
    end
  end

  describe 'Access restriction' do
    before do
      5.times { FactoryGirl.create :product }
      @cart = FactoryGirl.create :cart
      3.times do
        product = Product.all.sample
        @cart.line_items.create(product_id: product.id,
                                price: product.price,
                                quantity: rand(1..6))
      end
    end

    describe 'GET /carts/:cart_id' do
      it 'returns 401 unauthorized without auth_token' do
        get "/carts/#{@cart.id}", {}, 'Accept' => 'application/json'
        expect(response.status).to eq 401
      end
    end

    describe 'GET /carts/:cart_id/line_items' do
      it 'returns 401 unauthorized without auth_token' do
        get "/carts/#{@cart.id}/line_items", {}, 'Accept' => 'application/json'
        expect(response.status).to eq 401
      end
    end
  end
end
