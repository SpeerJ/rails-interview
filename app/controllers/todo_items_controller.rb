class TodoItemsController < ApplicationController
  before_action :set_todo_list
  before_action :set_todo_item, only: %i[ show edit update destroy toggle_completion]

  # GET /todo_list/1/todo_items
  def index
    @todo_items = @todo_list.todo_items
    @all_completed = !@todo_items.exists?(completed_at: nil)
  end

  # GET /todo_list/1/todo_items/1
  def show
  end

  # GET /todo_list/1/todo_items/new
  def new
    @todo_item = @todo_list.todo_items.build
  end

  # GET /todo_list/1/todo_items/1/edit
  def edit
  end

  # POST /todo_list/1/todo_items
  def create
    @todo_item = @todo_list.todo_items.build(todo_item_params)

    respond_to do |format|
      if @todo_item.save
        format.turbo_stream do
          # Update the index with the new val, replace the new form with the link to add a new item
          render turbo_stream:
                  [
                    turbo_stream.replace(
                      "todo_items",
                      partial: "todo_items/index",
                      locals: { todo_items: @todo_list.todo_items } ),
                    turbo_stream.replace("todo_item_form", partial: "todo_items/new")
                  ]
        end
        format.html { redirect_to todo_list_todo_item_path(@todo_item), notice: "Todo item was successfully created." }
      else
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todo_list/1/todo_items/1
  def update
    respond_to do |format|
      if @todo_item.update(todo_item_params)
        format.html { redirect_to todo_item_url(@todo_item), notice: "Todo item was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("todo_items", partial: "todo_items/index", locals: { todo_items: @todo_list.todo_items } ) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todo_list/1/todo_items/1
  def destroy
    @todo_item.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@todo_item) }
      format.html { redirect_to todo_items_url, notice: "Todo item was successfully destroyed." }
    end
  end

  # PATCH /todo_list/1/todo_items/1/toggle_completion
  def toggle_completion
    @todo_item.update(completed_at: @todo_item.completed? ? nil : Time.current)

    respond_to do |format|
      format.turbo_stream {
        @todo_items = @todo_list.todo_items
        # replace everything to avoid issue with padding
        render turbo_stream: turbo_stream.replace("todo_items", partial: "todo_items/index", locals: { todo_items: @todo_items } )
      }
      format.html { redirect_to @todo_list }
    end
  end

  # PATCH /todo_list/1/todo_items/toggle_completion
  def toggle_all_completed
    @all_were_completed = !@todo_list.todo_items.exists?(completed_at: nil)
    items_to_change = @all_were_completed ? @todo_list.todo_items : @todo_list.todo_items.where(completed_at: nil)
    items_to_change.update_all(completed_at: @all_were_completed ? nil : Time.current)

    @todo_items = @todo_list.todo_items
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace("todo_items", partial: "todo_items/index", locals: { todo_items: @todo_items } ) }
      format.html { redirect_to @todo_list }
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
    params.require(:todo_item).permit(:todo_lists_id, :name, :description, :completed_at)
  end
end
