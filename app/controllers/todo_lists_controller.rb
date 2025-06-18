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

    if @todo_list.save
      redirect_to todo_lists_path, notice: 'Todo list created successfully'
    else
      render :new
    end
  end

  private
  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end
end
