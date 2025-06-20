require 'rails_helper'

RSpec.describe "todo_items/show", type: :view do
  let!(:todo_list) {TodoList.create!(name: 'list')}

  before(:each) do
    assign(:todo_list, todo_list)
    assign(:todo_item, todo_list.todo_items.create!(
      name: "MyString",
      description: "MyString"
    ))
  end
end
