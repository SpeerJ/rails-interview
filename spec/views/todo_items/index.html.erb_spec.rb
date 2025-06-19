require 'rails_helper'

RSpec.describe "todo_items/index", type: :view do
  let(:todo_list) { TodoList.create!(name: "Sample List") }
  let!(:todo_items) do
    [
      TodoItem.create!(todo_list: todo_list, name: "Title 1", description: "Description 1"),
      TodoItem.create!(todo_list: todo_list, name: "Title 2", description: "Description 2"),

    ]
  end

  before do
    assign(:todo_list, todo_list)
    assign(:todo_items, todo_items)
    render
  end

  it "renders turbo frame tag wrapping todo_items with id 'todo_items'" do
    expect(rendered).to have_css('turbo-frame#todo_items, turbo-frame[name="todo_items"]')
  end

  it "renders a turbo frame for each todo_item with the correct dom_id" do
    todo_items.each do |item|
      expect(rendered).to have_css("turbo-frame##{dom_id(item)}, turbo-frame[name='#{dom_id(item)}']")
      expect(rendered).to match(/#{item.name}/)
      expect(rendered).to match(/#{item.description}/)
    end
  end

  it "renders the todo_item partial inside each turbo frame" do
    todo_items.each do |item|
      expect(rendered).to include(item.name)
      expect(rendered).to include(item.description)
    end
  end

  it "matches the overall todo_item count rendered" do
    # The presence of todo item titles repeated count check
    expect(rendered.scan(/Title/).size).to eq(todo_items.size)
  end
end
