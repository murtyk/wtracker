class Admin
  class CitiesController < ApplicationController
    before_filter :authenticate_admin!

    def show
      @city = City.find(params[:id])
    end

    def index
      if params[:filters]
        name = params[:filters][:name]
        state_id = params[:filters][:state_id].to_i
        cities = City.search(name, state_id)

        @total = cities.count
        @cities = cities.to_a.paginate(page: params[:page], per_page: 20)
      else
        @cities = []
      end
    end
  end
end
