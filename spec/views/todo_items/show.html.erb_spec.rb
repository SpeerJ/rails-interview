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

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Description/)
  end
end
