# frozen_string_literal: true

class ExpensesController < ApplicationController
  def new
    @expense = current_user.expenses.build
    @expense.shared_expenses.build
    load_user_list
  end

  def create
    @expense = current_user.expenses.build(expense_params)
    if @expense.save
      flash[:notice] = t('expense_created_successfully')
      redirect_to root_path
    else
      flash[:alert] = @expense.errors.full_messages.join(' <br> ')
      load_user_list
      render 'new'
    end
  end

  private

  def expense_params
    params.require(:expense).permit(:name, :description, :amount, :paid_by_id, :is_paid_by_me,
                                    shared_expenses_attributes: %i[id _destroy user_id])
  end

  def load_user_list
    @user_list = User.exclude_user(current_user.id)
  end
end
