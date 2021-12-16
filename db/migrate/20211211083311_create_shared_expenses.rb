# frozen_string_literal: true

class CreateSharedExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :shared_expenses do |t|
      t.belongs_to :user
      t.belongs_to :expense
      t.float :balance
      t.boolean :is_paid, default: false
      t.timestamps
    end
  end
end
