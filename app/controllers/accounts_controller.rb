class AccountsController < ApplicationController
  before_filter :authenticate_user!

  def trainee_options
    authorize current_account, :edit?
  end

  def update_trainee_options
    authorize current_account, :update?
    current_account.update_options(params[:account])
  end
end
