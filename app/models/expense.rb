# frozen_string_literal: true

class Expense < ApplicationRecord
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :paid_by, class_name: 'User', foreign_key: 'paid_by_id'
  has_many :shared_expenses, dependent: :delete_all

  validate :shared_expenses_presence

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :name, presence: true

  attr_accessor :is_paid_by_me

  accepts_nested_attributes_for :shared_expenses, allow_destroy: true

  before_save :set_is_paid

  def self.user_owe(user_id)
    joins(shared_expense_join(user_id))
      .where(shared_expenses: { is_paid: false })
  end

  def self.user_shared_expenses(user_id, friend_id)
    eager_load(:shared_expenses).where(paid_by_id: [user_id, friend_id],
                                       shared_expenses: { user_id: [user_id, friend_id], is_paid: false })
                                .select('expenses.*, shared_expenses.balance as balance')
                                .order('expenses.created_at desc')
  end

  private

  def shared_expenses_presence
    errors.add :base, :atleast_one_user unless shared_expenses.any?
  end

  def set_is_paid
    return unless is_paid_by_me == '1'

    self.paid_by = created_by
  end

  def self.shared_expense_join(user_id)
    <<-SQL.squish
      inner join shared_expenses on shared_expenses.expense_id
       = expenses.id and shared_expenses.user_id = #{user_id}
    SQL
  end

  def self.total_due_select(user_id)
    <<-SQL.squish
      expenses.* , sum(case when is_paid = false and user_id = #{user_id}
          then balance else -balance end) as total_due
    SQL
  end
end
