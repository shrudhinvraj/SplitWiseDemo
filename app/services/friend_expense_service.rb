# frozen_string_literal: true

class FriendExpenseService
  def initialize(user_id, friend_id)
    @user_id = user_id
    @friend_id = friend_id
  end

  def self.call(*args)
    new(*args).set_friend_data
  end

  def set_friend_data
    {
      expense_list: Expense.user_shared_expenses(@user_id, @friend_id),
      settlement_data: Settlement.user_settlements(@user_id)
                                 .user_settlements(@friend_id).order('created_at desc')
                                 .preload(:settlement_by, :settlement_to),
      friends_list: User.transacted_users(@user_id),
      selected_friend: User.find(@friend_id).name
    }
  end
end
