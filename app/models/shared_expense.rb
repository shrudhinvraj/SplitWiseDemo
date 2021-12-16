# frozen_string_literal: true

class SharedExpense < ApplicationRecord
  belongs_to :user
  belongs_to :expense

  before_create :set_balance

  def self.user_due(user_id)
    joins(:expense).where({ is_paid: false, expense: { paid_by_id: user_id } })
  end

  private

  def set_balance
    balance_amount = (expense.amount.to_f / expense.shared_expenses.length)
    self.balance = user == expense.paid_by ? balance_amount.ceil(2) : balance_amount.floor(2)
    self.is_paid = (user == expense.paid_by)
  end
end
