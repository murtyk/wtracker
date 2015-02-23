class Admin
  # for admin to view counties and pull polygons
  class CountiesController < ApplicationController
    before_filter :authenticate_admin!

    def show
      @county = County.find(params[:id])
    end

    def index
      if params[:filters]
        @counties = find_counties.to_a.paginate(page: params[:page], per_page: 20)
      else
        @counties = []
      end
    end

    private

    def find_counties
      @show_map = params[:filters][:map].to_i == 1
      counties, @county_polygons = County.search(params[:filters], @show_map)
      counties
    end
  end
end
