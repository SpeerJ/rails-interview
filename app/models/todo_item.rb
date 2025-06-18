class TodoItem < ApplicationRecord
  belongs_to :todo_list

  def completed?
    completion.present?
  end
end
