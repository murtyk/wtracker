class Admin
  class UsersController < ApplicationController
    before_filter :authenticate_admin!

    def index
      @account_id = (params[:filters] && params[:filters][:account_id]).to_i
      @online_only = (params[:filters] && params[:filters][:online_only]).to_i == 1
      if @account_id > 0
        users = User.unscoped.where(account_id: @account_id).order(:first, :last).decorate
      else
        users = User.unscoped.order(:account_id, :first, :last).decorate
      end
      users = users.map { |user| user if user.online? }.compact if @online_only
      @users = users.to_a.paginate(page: params[:page], per_page: 10)
    end
  end
end
