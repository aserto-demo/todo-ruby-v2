class CreateTodos < ActiveRecord::Migration[7.0]
  def change
    create_table :todos do |t|
      t.string :owner_id
      t.string :title
      t.boolean :completed

      t.timestamps
    end
    add_index :todos, :id
  end
end
