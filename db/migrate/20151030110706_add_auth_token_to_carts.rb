class AddAuthTokenToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :auth_token, :string
  end
end
