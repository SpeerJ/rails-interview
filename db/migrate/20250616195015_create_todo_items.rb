class CreateTodoItems < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_items do |t|
      t.references :todo_list, null: false, foreign_key: true
      t.string :name, null: false
      t.string :description
      t.datetime :completed_at

      t.timestamps
    end
  end
end
