class TodoItemsController < ApplicationController
  before_action :set_todo_list
  before_action :set_todo_item, only: %i[ show edit update destroy ]

  # GET /todo_items or /todo_items.json
  def index
    @todo_items = @todo_list.todo_items
  end

  # GET /todo_items/1 or /todo_items/1.json
  def show
  end

  # GET /todo_items/new
  def new
    @todo_item = @todo_list.todo_items.build
  end

  # GET /todo_items/1/edit
  def edit
  end

  # POST /todo_items or /todo_items.json
  def create
    @todo_item = @todo_list.todo_items.build(todo_item_params)

    respond_to do |format|
      if @todo_item.save
        format.turbo_stream
        format.html { redirect_to todo_list_item_path(@todo_item), notice: "Todo item was successfully created." }
      else
        format.turbo_stream { render :new, status: :unprocessable_entity}
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todo_items/1 or /todo_items/1.json
  def update
    respond_to do |format|
      if @todo_item.update(todo_item_params)
        format.html { redirect_to todo_item_url(@todo_item), notice: "Todo item was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todo_items/1 or /todo_items/1.json
  def destroy
    @todo_item.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@todo_item)}
      format.html { redirect_to todo_items_url, notice: "Todo item was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo_item
      @todo_item = TodoItem.find(params[:id])
    end

    def set_todo_list
      @todo_list = TodoList.find(params[:todo_list_id])
    end

    # Only allow a list of trusted parameters through.
    def todo_item_params
      params.require(:todo_item).permit(:todo_lists_id, :title, :description, :completion)
    end
end
