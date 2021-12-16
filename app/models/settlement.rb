# frozen_string_literal: true

class Settlement < ApplicationRecord
  belongs_to :settlement_by, class_name: 'User', foreign_key: 'settlement_by_id'
  belongs_to :settlement_to, class_name: 'User', foreign_key: 'settlement_to_id'

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :name, presence: true

  scope :user_settlements, lambda { |user_id|
                             where(['settlement_by_id in (:user_id) or settlement_to_id in (:user_id)', { user_id: user_id }])
                           }

  def self.settled_amount(friend_id)
    user_settlements(friend_id).sum(settlement_sum_query(friend_id))
  end

  def self.settlement_sum_query(friend_id)
    <<-SQL.squish
            case when settlement_to_id = #{friend_id} then amount else -amount end
    SQL
  end
end
