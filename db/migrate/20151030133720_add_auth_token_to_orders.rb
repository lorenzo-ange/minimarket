class AddAuthTokenToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :auth_token, :string
  end
end
