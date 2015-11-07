require 'rails_helper'

describe 'Product API' do
  describe 'GET /products' do
    before do
      FactoryGirl.create :product, title: 'The Lord of the Rings'
      FactoryGirl.create :product, title: 'The Two Towers'
    end

    it 'lists all the products' do
      get '/products', {}, 'Accept' => 'application/json'

      expect(response.status).to eq 200

      body = JSON.parse(response.body)
      products_titles = body.map { |m| m['title'] }

      expect(products_titles).to match_array(['The Lord of the Rings',
                                              'The Two Towers'])
    end
  end
end
