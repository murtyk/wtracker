class Api::V1::ApiBaseController < ApplicationController
  include Authenticable

  private

  def scope_current_account
    Account.current_id = current_account.id
    yield
  end
end
