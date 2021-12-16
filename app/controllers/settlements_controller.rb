# frozen_string_literal: true

class SettlementsController < ApplicationController
  def new
    @settlement = current_user.settlements.build
    load_user_list
  end

  def create
    @settlement = current_user.settlements.build(settlement_params)
    if @settlement.save
      flash[:notice] = t('settlment_created_successfully')
      redirect_to root_path
    else
      flash[:alert] = @settlement.errors.full_messages.join(' <br> ')
      load_user_list
      render 'new'
    end
  end

  private

  def settlement_params
    params.require(:settlement).permit(:name, :amount, :settlement_by_id, :settlement_to_id)
  end

  def load_user_list
    @user_list = User.transacted_users(current_user.id)
  end
end
