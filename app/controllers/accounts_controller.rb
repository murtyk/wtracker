class AccountsController < ApplicationController
  before_filter :authenticate_user!
  before_action :check_authorization
  # GET /acounts/trainee_options
  def trainee_options
  end

  def update_trainee_options
    current_account.update_options(params[:account])
  end

  private

  def check_authorization
    fail User::NotAuthorized unless current_user.admin_or_director? || current_user.grant_admin?
  end
end
