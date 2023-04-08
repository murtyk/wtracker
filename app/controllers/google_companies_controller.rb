# frozen_string_literal: true

class GoogleCompaniesController < ApplicationController
  before_filter :authenticate_user!

  # google search menu.
  def index
    @companies = CompanyFinder.google_search(params[:filters]) if params[:filters]
    @companies ||= []
  end
end
