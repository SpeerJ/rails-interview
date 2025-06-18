module Api
  class TodoItemsController < ApiController
    before_action :set_todo_item, only: [:show, :update, :destroy]

    # GET /api/todo_items
    def index
      @todo_list = TodoList.find(params[:todo_list_id])
      @todo_items = @todo_list.todo_items
      render json: @todo_items
    end

    # GET /api/todo_items/1
    def show
      render json: @todo_item
    end

    # POST /api/todo_items
    def create
      @todo_list = TodoList.find(params[:todo_list_id])
      @todo_item = @todo_list.todo_items.build(todo_item_params)

      if @todo_item.save
        render json: @todo_item, status: :created, location: api_todo_list_todo_item_url(@todo_list, @todo_item)
      else
        render json: @todo_item.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/todo_items/1
    def update
      if @todo_item.update(todo_item_params)
        render json: @todo_item
      else
        render json: @todo_item.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/todo_items/1
    def destroy
      @todo_item.destroy
      head :no_content
    end

    private

    def set_todo_item
      # access item throught todo list to ensure we're deleting the right items
      @todo_item = TodoList.find(params[:todo_list_id]).todo_items.find(params[:id])
    end

    def todo_item_params
      params.require(:todo_item).permit(:title, :description, :completion, :todo_list_id)
    end
  end

end