# frozen_string_literal: true

module Api
  module V1
    class ApiBaseController < ApplicationController
      include Authenticable

      private

      def scope_current_account
        Account.current_id = current_account.id
        yield
      end
    end
  end
end
