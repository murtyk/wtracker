# frozen_string_literal: true

class Admin
  # for admin to search for a city or get it added
  class CitiesController < ApplicationController
    before_action :authenticate_admin!

    def show
      @city = City.find(params[:id])
    end

    def index
      @cities = if params[:filters]
                  find_cities.paginate(page: params[:page], per_page: 30)
                else
                  []
                end
    end

    private

    def find_cities
      name     = params[:filters][:name]
      state_id = params[:filters][:state_id].to_i
      cities   = City.search(name, state_id)

      @total   = cities.count
      cities
    end
  end
end
