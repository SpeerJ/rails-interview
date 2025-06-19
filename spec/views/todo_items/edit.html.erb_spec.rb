# spec/views/todo_items/edit.html.erb_spec.rb
require 'rails_helper'

## It's important that these exist as a fallback to turbo for cases where js isn't working
RSpec.describe "todo_items/edit", type: :view do
  let(:todo_list) {
    TodoList.create!(
      name: 'Sample Todo List'
    )
  }

  let(:todo_item) {
    todo_list.todo_items.create!(
      name: "MyTask",
      description: "Task description"
    )
  }

  before(:each) do
    assign(:todo_list, todo_list)
    assign(:todo_item, todo_item)
    render
  end

  it "displays the header 'Editing todo item'" do
    expect(rendered).to have_selector("h1", text: "Editing todo item")
  end

  it "renders the form with the correct action and method" do
    expect(rendered).to have_selector("form[action='#{todo_list_todo_item_path(todo_list, todo_item)}'][method='post']")
  end

  it "displays the current todo_item name in the title text field" do
    expect(rendered).to have_field("todo_item_name", with: todo_item.name)
  end

  it "displays the current todo_item description in the description textarea" do
    expect(rendered).to have_field("todo_item_description", with: todo_item.description)
  end

  it "displays a submit button within the form" do
    expect(rendered).to have_selector("input[type=submit]")
  end

  it "has a link to show this todo item" do
    expect(rendered).to have_link("Show this todo item", href: todo_list_todo_items_path(todo_item.id))
  end

  it "has a link to go back to todo items list" do
    expect(rendered).to have_link("Back to todo items", href: todo_list_todo_items_path(todo_list))
  end

  context "when there are errors on the todo item" do
    before do
      todo_item.errors.add(:name, "can't be blank")
      assign(:todo_item, todo_item)
      render
    end

    it "renders the errors block" do
      expect(rendered).to have_content("1 error prohibited this todo_item from being saved:")
      expect(rendered).to have_content("Name can't be blank")
      expect(rendered).to have_css('div', style: /color:\s*red/)
    end
  end
end
