class Admin
  class AccountsController < ApplicationController
    before_filter :authenticate_admin!

    # GET /accounts
    # GET /accounts.json
    def index
      @accounts = Account.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @accounts }
      end
    end

    # GET /accounts/1
    # GET /accounts/1.json
    def show
      @account = Account.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @account }
      end
    end

    # GET /accounts/new
    # GET /accounts/new.json
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
    # POST /accounts.json
    def create
      user_params = params[:account][:users_attributes]['0']

      # debugger
      user_params[:password_confirmation] = user_params[:password]
      user_params[:status] = 1
      user_params[:role] = 1
      @account = Account.new(params[:account])
      respond_to do |format|
        if @account.save
          notice = 'Account was successfully created.'
          notice += ' Please wait for a minute to generate ' \
                    'data for this demo account' if @account.demo
          format.html { redirect_to admin_account_path(@account), notice: notice }
        else
          format.html { render :new }
        end
      end
    end

    # PUT /accounts/1
    # PUT /accounts/1.json
    def update
      @account = Account.find(params[:id])

      respond_to do |format|
        if @account.update_attributes(params[:account])
          notice = 'Account was successfully updated.'
          format.html { redirect_to [:admin, @account], notice: notice }
          format.json { head :no_content }
        else
          format.html { render :edit }
          format.json { render json: @account.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /accounts/1
    # DELETE /accounts/1.json
    def destroy
      @account = Account.find(params[:id])
      @account.destroy
    end

    def stats
      @stats = AccountStats.generate(params[:id])
    end
  end
end
