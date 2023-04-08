# frozen_string_literal: true

class Admin
  # For admin to view all users
  class UsersController < ApplicationController
    before_filter :authenticate_admin!

    def index
      init_filters
      @users = find_users
    end

    private

    def init_filters
      @account_id = (params[:filters] && params[:filters][:account_id]).to_i
      @online_only = (params[:filters] && params[:filters][:online_only]).to_i == 1
    end

    def find_users
      users = account_users.paginate(page: params[:page], per_page: 30).decorate

      return users unless @online_only

      users.map { |user| user if user.online? }.compact if @online_only
    end

    def account_users
      return User.unscoped.order(:account_id, :first, :last) if @account_id.zero?

      User.unscoped.where(account_id: @account_id).order(:first, :last)
    end
  end
end
