class LineItemsController < ApplicationController
  include CurrentCart
  before_action :set_cart, only: [:create]
  before_action :set_line_item, only: %i[show edit update destroy]
  # GET /line_items or /line_items.json
  def index
    @line_items = LineItem.all
  end

  # GET /line_items/1 or /line_items/1.json
  def show; end

  # GET /line_items/new
  def new
    @line_item = LineItem.new
  end

  # GET /line_items/1/edit
  def edit; end

  # POST /line_items or /line_items.json
  def create
    product = Product.find(params[:product_id])
    @line_item = @cart.add_product(product)
    session[:counter] = 0

    respond_to do |format|
      if @line_item.save
        # The way to read this code is as follows: whenever we get a request that accepts a turbo stream response, we render a turbo stream response consisting of turbo stream replace specifying:

        # an HTML element ID of cart as the element to be replaced,
        # rendering the partial form app/views/application/_cart.html.erb
        # using the value of @cart as the value of cart.

        # format.turbo_stream do
        #   render turbo_stream: turbo_stream.replace(
        #     :cart, # id of HTML elem to be replaced
        #     partial: 'layouts/cart', # partial to render
        #     locals: { cart: @cart } # values
        #   )
        # end

        # renders line_items#create.turbo_stream.erb
        # @current_item is the last added item, needed for css animation
        format.turbo_stream { @current_item = @line_item }
        format.html { redirect_to store_index_url }
        format.json { render :show, status: :created, location: @line_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /line_items/1 or /line_items/1.json
  def update
    respond_to do |format|
      if @line_item.update(line_item_params)
        format.html { redirect_to line_item_url(@line_item), notice: 'Line item was successfully updated.' }
        format.json { render :show, status: :ok, location: @line_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /line_items/1 or /line_items/1.json
  def destroy
    @line_item.decrement!(:quantity)
    @line_item.destroy if @line_item.quantity.zero?

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to store_index_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_line_item
    @line_item = LineItem.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def line_item_params
    params.require(:line_item).permit(:product_id)
  end
end
