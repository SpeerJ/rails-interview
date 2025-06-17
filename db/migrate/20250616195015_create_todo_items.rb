class CreateTodoItems < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_items do |t|
      t.references :todo_lists, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.datetime :completion

      t.timestamps
    end
  end
end
