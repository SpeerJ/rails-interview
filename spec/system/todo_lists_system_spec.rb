require 'rails_helper'

RSpec.describe "TodoLists", type: :system do
  before do
    driven_by(:selenium, using: :firefox)
  end

  let!(:todo_list) { TodoList.create!(name: "Chores") }
  let!(:todo_item) { todo_list.todo_items.create!(name: "Take out trash", description: "Evening chore") }

  it "allows a user to view todo items for a todo list" do
    visit todo_lists_path
    expect(page).to have_content("Chores")

    # Click on the list name or a link to view items (adjust selector as needed)
    click_on "View Todo Items"

    expect(page).to have_content("Todo Items")
    expect(page).to have_content("Take out trash")
    expect(page).to have_content("Evening chore")
  end

  it "allows a user to add a new todo list" do
    visit todo_lists_path

    click_on 'Add Todo List' # button or link, if named differently adjust accordingly

    within('form#new_todo_list, form[action="/todo_lists"]') do
      fill_in 'todo_list[name]', with: 'Shopping'
      click_on 'Save'
    end

    expect(page).to have_content('Shopping')
    expect(page).to_not have_content('Name:')
  end
end