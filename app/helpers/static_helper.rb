# frozen_string_literal: true

module StaticHelper
  def paid_text(expense, friend_name)
    paid_name = current_user == expense.paid_by ? 'you' : friend_name
    t('paid_text', name: paid_name)
  end

  def owes_text(expense)
    action = current_user == expense.paid_by ? 'lent_text' : 'borrowed_text'
    t(action)
  end
end
