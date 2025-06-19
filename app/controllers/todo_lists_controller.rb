class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[show]

  # GET /todo_lists
  def index
    @todo_lists = TodoList.all

    respond_to :html
  end

  def show
    @todo_items = @todo_list.todo_items
  end

  # GET /todo_lists/new
  def new
    @todo_list = TodoList.new

    respond_to :html
  end

  def create
    @todo_list = TodoList.new(todo_list_params)

    respond_to do |format|
      if @todo_list.save
        format.html { redirect_to todo_lists_path, notice: 'Todo list created successfully' }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(
            "todo_lists",
            partial: "todo_lists/index",
            locals: { todo_lists: TodoList.all } ),
            turbo_stream.replace("todo_list_form", partial: "todo_lists/new")
          ]
        }
      else
        format.html { render :new }
        format.turbo_stream { render :new }
      end
    end
  end

  private
  def todo_list_params
    params.require(:todo_list).permit(:name)
  end

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end
end
