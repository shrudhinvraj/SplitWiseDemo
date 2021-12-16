# frozen_string_literal: true

class DashboardService
  def initialize(user_id)
    @user_id = user_id
  end

  def self.call(_current_user)
    new(_current_user).set_dashboard_data
  end

  def set_dashboard_data
    due_data = SharedExpense.user_due(@user_id)
    owe_data = Expense.user_owe(@user_id)
    settlements = Settlement.user_settlements(@user_id)
    {
      total_statistics: process_total_statistics(due_data, owe_data, settlements),
      overall_expense_data: process_dues_and_owes(due_data, owe_data, settlements),
      user_list: User.transacted_users(@user_id)
    }
  end

  private

  def process_dues_and_owes(due_data, owe_data, settlements)
    @overall_data_hash = { due_data: [], owe_data: [] }
    @processed_users = []
    owes = owe_data.select('paid_by_id, sum(shared_expenses.balance) as balance').group(:paid_by_id).preload(:paid_by)
    dues = due_data.select('user_id, sum(balance) as balance').group('user_id').preload(:user)
    process_owes(owes, dues, settlements)
    process_dues(owes, dues, settlements)
    @overall_data_hash
  end

  def process_owes(owes, dues, settlements)
    owes.each do |owe|
      @processed_users.push owe.paid_by_id
      due = dues.detect { |due| due.user_id == owe.paid_by_id }
      settled_amount = settlements.settled_amount(owe.paid_by_id).to_f
      store_due_or_owe(owe, due, settled_amount)
    end
  end

  def process_dues(_owes, dues, settlements)
    dues.each do |due|
      next if @processed_users.include? due.user_id

      settled_amount = settlements.settled_amount(due.user_id).to_f
      due.balance = due.balance + settled_amount
      @overall_data_hash[:due_data].push due
    end
  end

  def store_due_or_owe(owe, due = nil, settled_amount = 0)
    if due.present?
      if (due.balance + settled_amount) > owe.balance
        due.balance = ((due.balance + settled_amount) - owe.balance)
        @overall_data_hash[:due_data].push due
      else
        owe.balance = (owe.balance - (due.balance + settled_amount))
        @overall_data_hash[:owe_data].push owe
      end
    elsif settled_amount > owe.balance
      new_due = OpenStruct.new({ balance: (settled_amount - owe.balance), user: owe.paid_by })
      @overall_data_hash[:due_data].push new_due
    else
      owe.balance = (owe.balance - settled_amount)
      @overall_data_hash[:owe_data].push owe
    end
  end

  def process_total_statistics(due_data, owe_data, settlements)
    total_owe = calculate_total_owe(owe_data, settlements)
    total_due = calculate_total_due(due_data, settlements)
    {
      total_owe: total_owe,
      total_due: total_due,
      total_balance: total_owe - total_due
    }
  end

  def calculate_total_owe(owe_data, settlements)
    owe_settled = settlements.user_settlements(owe_data.pluck(:paid_by_id)).settled_amount(@user_id)
    owe_data.sum('balance') + owe_settled
  end

  def calculate_total_due(due_data, settlements)
    due_settled = settlements.user_settlements(due_data.pluck(:user_id)).settled_amount(@user_id)
    due_data.sum('balance') - due_settled
  end
end
