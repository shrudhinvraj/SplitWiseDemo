# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  validates :name, presence: true

  has_many :shared_expenses

  has_many :expenses, foreign_key: 'created_by_id'

  has_many :settlements, foreign_key: 'settlement_by_id'

  scope :exclude_user, ->(user_id) { where.not(id: user_id) }

  def self.transacted_users(user_id)
    where(transacted_ids(user_id)).group(:id)
  end

  def self.transacted_ids(user_id)
    <<-SQL.squish
      (users.id in ( select paid_by_id from expenses inner join shared_expenses on
         shared_expenses.expense_id = expenses.id where user_id = #{user_id}) or#{' '}
         users.id in (select user_id from shared_expenses inner join expenses on#{' '}
         shared_expenses.expense_id = expenses.id where paid_by_id = #{user_id}))
         and users.id != #{user_id}
    SQL
  end
end
