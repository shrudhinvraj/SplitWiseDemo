# frozen_string_literal: true

class StaticController < ApplicationController
  def dashboard
    @dashboard_data = DashboardService.call(current_user.id)
  end

  def person
    @shared_expense_data = FriendExpenseService.call(current_user.id, params[:id])
  end
end
