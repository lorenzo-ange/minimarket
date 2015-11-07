require 'rails_helper'

describe 'Order API' do
  describe 'POST /orders' do
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

    it 'creates a new order' do
      order_params = {
        'order' => {
          'name' => Faker::Name.name,
          'address' => "#{Faker::Address.street_address} #{Faker::Address.city} (#{Faker::Address.zip_code})",
          'email' => Faker::Internet.email,
          'pay_type' => Order::PAYMENT_TYPES.sample
        },
        'cart_id' => @cart.id,
        'cart_auth_token' => @cart.auth_token
      }.to_json

      request_headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }

      post '/orders', order_params, request_headers

      expect(response.status).to eq 201 # created

      body = JSON.parse(response.body)
      order = Order.find(body['id'])

      expect(Cart.count).to eq 0
      expect(Order.count).to eq 1
      expect(order.line_items.count).to eq 3
    end
  end

  describe 'GET /orders/:order_id' do
    before do
      5.times { FactoryGirl.create :product }
      @order = FactoryGirl.create :order
      3.times do
        product = Product.all.sample
        @order.line_items.create(product_id: product.id,
                                 price: product.price,
                                 quantity: rand(1..6))
      end
    end

    it 'shows the order' do
      get "/orders/#{@order.id}",
          { 'auth_token' => @order.auth_token },
          'Accept' => 'application/json'

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      expect(body['id']).to eq @order.id
      expect(body['name']).to eq @order.name
      expect(body['email']).to eq @order.email
      expect(body['pay_type']).to eq @order.pay_type
      expect(body['auth_token']).to eq @order.auth_token
    end
  end

  describe 'GET /orders/:order_id/line_items' do
    before do
      5.times { FactoryGirl.create :product }
      @order = FactoryGirl.create :order
      3.times do
        product = Product.all.sample
        @order.line_items.create(product_id: product.id,
                                 price: product.price,
                                 quantity: rand(1..6))
      end
    end

    it 'lists all the line items for the order' do
      get "/orders/#{@order.id}/line_items",
          { 'auth_token' => @order.auth_token },
          'Accept' => 'application/json'

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      line_items_ids = body.map { |m| m['id'] }
      real_line_items_ids = @order.line_items.map(&:id)

      expect(line_items_ids.count).to eq 3
      expect(line_items_ids).to match_array(real_line_items_ids)
    end
  end

  describe 'Access restriction' do
    before do
      5.times { FactoryGirl.create :product }
      @order = FactoryGirl.create :order
      3.times do
        product = Product.all.sample
        @order.line_items.create(product_id: product.id,
                                 price: product.price,
                                 quantity: rand(1..6))
      end
    end

    describe 'GET /orders/:order_id' do
      it 'returns 401 unauthorized without auth_token' do
        get "/orders/#{@order.id}", {}, 'Accept' => 'application/json'
        expect(response.status).to eq 401
      end
    end

    describe 'GET /orders/:order_id/line_items' do
      it 'returns 401 unauthorized without auth_token' do
        get "/orders/#{@order.id}/line_items", {}, 'Accept' => 'application/json'
        expect(response.status).to eq 401
      end
    end
  end
end
