module Api
  class TodoListsController < ApplicationController
    skip_before_action :verify_authenticity_token

    # GET /api/todolists
    def index
      @todo_lists = TodoList.all

      respond_to :json
    end

    # create, update, destroy

    def create
      @todo_list = TodoList.create(todo_list_params)

      respond_to do |format|
        format.json { render json: @todo_list, status: :created }
      end
    end

    # title, description, completion

    def update
      @todo_list = TodoList.find(params[:id])
      @todo_list.update(todo_list_params)

      respond_to do |format|
        format.json { render json: @todo_list }
      end
    end

    def destroy
      @todo_list = TodoList.find(params[:id])
      @todo_list.destroy

      respond_to do |format|
        format.json { head :no_content }
      end
    end

    private

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end

  end
end
