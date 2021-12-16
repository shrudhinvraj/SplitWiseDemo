# frozen_string_literal: true

class CreateExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :expenses do |t|
      t.string :name
      t.text :description
      t.float :amount
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :paid_by, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
