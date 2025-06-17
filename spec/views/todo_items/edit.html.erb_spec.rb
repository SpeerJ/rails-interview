require 'rails_helper'

RSpec.describe "todo_items/edit", type: :view do
  let(:todo_item) {
    TodoItem.create!(
      todo_lists: nil,
      title: "MyString",
      description: "MyString"
    )
  }

  before(:each) do
    assign(:todo_item, todo_item)
  end

  it "renders the edit todo_item form" do
    render

    assert_select "form[action=?][method=?]", todo_item_path(todo_item), "post" do

      assert_select "input[name=?]", "todo_item[todo_lists_id]"

      assert_select "input[name=?]", "todo_item[title]"

      assert_select "input[name=?]", "todo_item[description]"
    end
  end
end
