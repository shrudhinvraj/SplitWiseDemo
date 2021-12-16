# frozen_string_literal: true

class CreateSettlements < ActiveRecord::Migration[6.1]
  def change
    create_table :settlements do |t|
      t.string :name
      t.float :amount
      t.references :settlement_by, null: false, foreign_key: { to_table: :users }
      t.references :settlement_to, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
