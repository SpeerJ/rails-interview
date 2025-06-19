# Most of the testing here has already been done in #edit, since they both use _form
require 'rails_helper'

RSpec.describe "todo_items/new", type: :view do
  before(:each) do
    assign(:todo_list, TodoList.new(id: 1))
    assign(:todo_item, TodoItem.new(
      todo_list: nil,
      name: "MyString",
      description: "MyString"
    ))
  end

  it "renders the new todo item form inside turbo frame" do
    render

    # Verify turbo frame wrapper
    expect(rendered).to have_selector("turbo-frame#new_todo_item")

    # Verify that the form partial is rendered (simple check for form tag)
    expect(rendered).to have_selector("form")
  end
end
