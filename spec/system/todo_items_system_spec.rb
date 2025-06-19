require 'rails_helper'

RSpec.describe "TodoItems", type: :system do
  before do
    driven_by(:selenium, using: :firefox)
  end

  let!(:todo_list) { TodoList.create!(name: "My Test List") }

  it "allows a user to create a new todo item" do
    visit todo_list_todo_items_path(todo_list_id: todo_list.id)

    click_on 'Add Todo Item'

    within('turbo-frame#todo_item_form') do
      fill_in 'todo_item[name]', with: 'A brand new item'
      fill_in 'todo_item[description]', with: 'With a nice description'
      click_on 'Save'
    end

    expect(page).to have_content('A brand new item')

    within('turbo-frame#todo_item_form') do
      expect(page).to have_content('➕')
    end
  end

  context "with an existing todo item" do
    let!(:todo_item) { todo_list.todo_items.create!(name: "First Item", description: "First Description") }

    it "allows a user to toggle an item to completed" do
      visit todo_list_todo_items_path(todo_list_id: todo_list.id)

      expect(page).not_to have_content("Completed At:")

      within "#todo_item_#{todo_item.id} .todo-item-checkbox form" do
        check "completed"
      end

      expect(page).to have_content("Completed At:")
      within "#todo_item_#{todo_item.id} #todo_item_#{todo_item.id}" do
        expect(page).to have_checked_field("completed")
      end
    end
  end

  context "with multiple todo items" do
    let!(:item1) { todo_list.todo_items.create!(name: "Item 1", description: "Desc 1") }
    let!(:item2) { todo_list.todo_items.create!(name: "Item 2", description: "Desc 2") }

    it "allows toggling all items to completed" do
      visit todo_list_todo_items_path(todo_list_id: todo_list.id)

      expect(page).not_to have_content("Completed At:")
      expect(page).to have_unchecked_field("complete_all")

      check "Complete All"

      # The whole list should be re-rendered, with all items completed.
      expect(page).to have_content("Completed At:", count: 2)
      expect(page).to have_checked_field("Complete All")
      expect(find("#todo_item_#{item1.id} #completed")).to be_checked
      expect(find("#todo_item_#{item2.id} #completed")).to be_checked
    end

    it "allows toggling all to completed when some are already completed" do
      item1.update!(completed_at: Time.current)
      visit todo_list_todo_items_path(todo_list_id: todo_list.id)

      expect(page).to have_content("Completed At:", count: 1)
      expect(page).to have_unchecked_field("Complete All")

      check "Complete All"

      expect(page).to have_content("Completed At:", count: 2)
      expect(page).to have_checked_field("Complete All")
      expect(find("#todo_item_#{item1.id} #completed")).to be_checked
      expect(find("#todo_item_#{item2.id} #completed")).to be_checked
    end

    # Test 5: Toggling off all items when all are completed
    it "allows toggling off all items when all are completed" do
      item1.update!(completed_at: Time.current)
      item2.update!(completed_at: Time.current)
      visit todo_list_todo_items_path(todo_list_id: todo_list.id)

      expect(page).to have_content("Completed At:", count: 2)
      expect(page).to have_checked_field("Complete All")

      uncheck "Complete All"

      expect(page).not_to have_content("Completed At:")
      expect(page).to have_unchecked_field("Complete All")
      expect(find("#todo_item_#{item1.id} #completed")).not_to be_checked
      expect(find("#todo_item_#{item2.id} #completed")).not_to be_checked
    end
  end
end