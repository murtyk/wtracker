class Admin
  # for opero admin to manage states assigned to an account
  class AccountStatesController < ApplicationController
    before_filter :authenticate_admin!

    # GET /account_states/new.js
    def new
      account = Account.find(params[:account_id])
      @account_state = account.account_states.build
    end

    # POST /account_states.js
    def create
      @account_state = AccountState.new(params[:account_state])
      @account_state.save
    end

    # DELETE /account_states/1.js
    def destroy
      @account_state = AccountState.find(params[:id])
      @account_state.destroy
    end
  end
end
