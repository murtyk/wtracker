# frozen_string_literal: true

class Admin
  # for opero admin to manage accounts
  class AccountsController < ApplicationController
    before_filter :authenticate_admin!

    # GET /accounts
    def index
      @accounts = Account.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @accounts }
      end
    end

    # GET /accounts/1
    def show
      @account = Account.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @account }
      end
    end

    # GET /accounts/new
    def new
      @account = Account.new
      @account.users.build

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @account }
      end
    end

    # GET /accounts/1/edit
    def edit
      @account = Account.find(params[:id])
    end

    # POST /accounts
    def create
      set_up_user_params
      @account = Account.new(account_params)

      if @account.save
        notice = 'Account was successfully created.'
        if @account.demo
          notice += ' Please wait for a minute to generate ' \
                    'data for this demo account'
        end
        redirect_to admin_account_path(@account), notice: notice
      else
        render :new
      end
    end

    # PUT /accounts/1
    def update
      @account = Account.find(params[:id])

      if @account.update_attributes(account_params)
        notice = 'Account was successfully updated.'
        redirect_to [:admin, @account], notice: notice
      else
        render :edit
      end
    end

    # DELETE /accounts/1
    def destroy
      @account = Account.find(params[:id])
      prev_id = Account.current_id
      Account.current_id = @account.id

      @account.destroy_all_dependends

      @account.grants.each do |g|
        Grant.current_id = g.id
        g.destroy
      end

      @account.destroy
      Account.current_id = prev_id
    end

    def stats
      @stats = AccountStats.new(params[:id])
    end

    private

    def set_up_user_params
      user_params = params[:account][:users_attributes]['0']

      user_params[:password_confirmation] = user_params[:password]
      user_params[:status] = 1
      user_params[:role] = 1
    end

    def account_params
      params.require(:account)
            .permit(:options, :description, :name, :status, :client_type,
                    :subdomain, :logo_file, :demo,
                    users_attributes: %i[first last email password
                                         password_confirmation role status location])
    end
  end
end
