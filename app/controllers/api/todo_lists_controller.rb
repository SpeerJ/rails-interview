module Api
  class TodoListsController < ApiController
   # GET /api/todo_lists
    def index
      @todo_lists = TodoList.all
      render json: @todo_lists
    end

    # POST /api/todo_lists
    def create
      @todo_list = TodoList.new(todo_list_params)

      if @todo_list.save
        render json: @todo_list, status: :created
      else
        render json: @todo_list.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/todo_lists
    def update
      @todo_list = TodoList.find(params[:id])

      if @todo_list.update(todo_list_params)
        render json: @todo_list, status: :ok
      else
        render json: @todo_list.errors, status: :unprocessable_entity
      end
    end

    # DESTROY /api/todo_lists/:id
    def destroy
      @todo_list = TodoList.find(params[:id])

      if @todo_list.destroy
        head :no_content
      else
        render json: { error: "Could not destroy resource" }, status: :unprocessable_entity
      end
    end
  end
end