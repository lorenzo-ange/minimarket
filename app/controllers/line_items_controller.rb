class LineItemsController < ApplicationController
  before_action :ensure_not_order, only: [:create, :update, :destroy]
  before_action :set_owner
  before_action :set_line_item, only: [:show, :update, :destroy]
  append_before_action :restrict_access

  def index
    render json: @owner.line_items
  end

  def show
    render json: @line_item
  end

  def create
    @cart = @owner
    @line_item = @cart.line_items.build(line_item_params)

    if @line_item.save
      render json: @line_item, status: :created, location: cart_line_item_url(@cart, @line_item)
    else
      render json: @line_item.errors, status: :unprocessable_entity
    end
  end

  def update
    @line_item = LineItem.find(params[:id])

    if @line_item.update(line_item_params)
      head :no_content
    else
      render json: @line_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @line_item.destroy

    head :no_content
  end

  private

    def ensure_not_order
      head :unauthorized if params[:order_id]
    end

    def set_owner
      if params[:cart_id]
        @owner = Cart.find(params[:cart_id])
      elsif params[:order_id]
        @owner = Order.find(params[:order_id])
      end
    end

    def set_line_item
      @line_item = LineItem.find(params[:id])
    end

    def line_item_params
      params.require(:line_item).permit(:quantity, :price, :product_id)
    end

    def restrict_access
      head :unauthorized unless params[:auth_token] == @owner.auth_token
    end
end
