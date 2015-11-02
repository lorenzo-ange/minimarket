class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :update, :destroy]
  append_before_action :restrict_access, only: [:show, :update, :destroy]

  # GET /carts
  # GET /carts.json
  def index
    head :unauthorized
  end

  # GET /carts/1
  # GET /carts/1.json
  def show
    render json: @cart
  end

  # POST /carts
  # POST /carts.json
  def create
    @cart = Cart.new(cart_params)

    if @cart.save
      render json: @cart, status: :created, location: @cart
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /carts/1
  # PATCH/PUT /carts/1.json
  def update
    @cart = Cart.find(params[:id])

    if @cart.update(cart_params)
      head :no_content
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart.destroy

    head :no_content
  end

  private

    def set_cart
      @cart = Cart.find(params[:id])
    end

    def cart_params
      params[:cart]
    end

    def restrict_access
      head :unauthorized unless params[:auth_token] == @cart.auth_token
    end
end
