# frozen_string_literal: true

class AccountsController < ApplicationController
  before_filter :authenticate_user!

  def trainee_options
    authorize current_account, :edit?
  end

  def update_trainee_options
    authorize current_account, :update?
    current_account.update_options(account_params)
  end

  private

  def account_params
    params.require(:account).permit(:options, :track_trainee, :mark_jobs_applied)
  end
end
