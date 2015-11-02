class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :update, :destroy]
  append_before_action :restrict_access, only: [:show, :update, :destroy]

  before_action :set_cart, only: :create
  append_before_action :ensure_cart_owner, only: :create

  # GET /orders
  # GET /orders.json
  def index
    head :unauthorized
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    render json: @order
  end

  # POST /orders
  # POST /orders.json
  def create
    @order, @errors = Order.create_from_cart(@cart, order_params)

    if @order
      render json: @order, status: :created, location: @order
    else
      render json: @errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    head :unauthorized
    # @order = Order.find(params[:id])
    #
    # if @order.update(order_params)
    #   head :no_content
    # else
    #   render json: @order.errors, status: :unprocessable_entity
    # end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    head :unauthorized
    # @order.destroy
    #
    # head :no_content
  end

  private

    def set_cart
      @cart = Cart.find(params[:cart_id])
    end

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:name, :address, :email, :pay_type)
    end

    def ensure_cart_owner
      head :unauthorized unless params[:cart_auth_token] == @cart.auth_token
    end

    def restrict_access
      head :unauthorized unless params[:auth_token] == @order.auth_token
    end
end
