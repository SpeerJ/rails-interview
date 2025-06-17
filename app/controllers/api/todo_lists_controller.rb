module Api
  class TodoListsController < ApplicationController
    skip_before_action :verify_authenticity_token
    rescue_from StandardError, with: :render_internal_server_error_response # Catch-all for other errors
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

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

    private

    def todo_list_params
      params.require(:todo_list).permit(:name)
    end

    def render_not_found_response
      render json: { error: "Resource not found" }, status: :not_found
    end

    def render_parameter_missing_response(exception)
      render json: { error: exception.message }, status: :bad_request
    end

    # Generic error handler for any other unhandled exceptions.
    # added to avoid html responses when testing in dev
    def render_internal_server_error_response(exception)
      error_response = { error: "Internal Server Error" }

      unless Rails.env.production?
        error_response[:details] = exception.message # Can be sensitive in prod environs
      end

      render json: error_response, status: :internal_server_error
    end
  end
end