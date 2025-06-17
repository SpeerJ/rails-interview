class TodoList < ApplicationRecord
  has_many :todo_items, dependent: :destroy, foreign_key: 'todo_lists_id'
end