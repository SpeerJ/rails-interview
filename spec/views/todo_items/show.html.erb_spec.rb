require 'rails_helper'

RSpec.describe "todo_items/show", type: :view do
  before(:each) do
    assign(:todo_item, TodoItem.create!(
      todo_lists: nil,
      name: "Title",
      description: "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Description/)
  end
end
