require 'rails_helper'

RSpec.describe "todo_items/new", type: :view do
  before(:each) do
    assign(:todo_item, TodoItem.new(
      todo_lists: nil,
      title: "MyString",
      description: "MyString"
    ))
  end

  it "renders new todo_item form" do
    render

    assert_select "form[action=?][method=?]", todo_items_path, "post" do

      assert_select "input[name=?]", "todo_item[todo_lists_id]"

      assert_select "input[name=?]", "todo_item[title]"

      assert_select "input[name=?]", "todo_item[description]"
    end
  end
end
