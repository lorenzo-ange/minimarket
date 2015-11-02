require 'test_helper'

class CartsControllerTest < ActionController::TestCase
  setup do
    @cart = carts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:carts)
  end

  test "should create cart" do
    assert_difference('Cart.count') do
      post :create, cart: {  }
    end

    assert_response 201
  end

  test "should show cart" do
    get :show, id: @cart
    assert_response :success
  end

  test "should update cart" do
    put :update, id: @cart, cart: {  }
    assert_response 204
  end

  test "should destroy cart" do
    assert_difference('Cart.count', -1) do
      delete :destroy, id: @cart
    end

    assert_response 204
  end
end
