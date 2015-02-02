# Opero administrator maintains grant
class Admin
  # Opero administrator maintains grant
  class GrantsController < ApplicationController
    before_filter :authenticate_admin!

    def new
      @grant = GrantFactory.new_grant(params[:account_id])
      respond_to do |format|
        format.html
        format.json { render json: @grant }
      end
    end

    def create
      @grant = GrantFactory.build_grant(params[:grant])
      if @grant.errors.empty? && @grant.save
        notice = 'Grant was successfully created.'
        redirect_to(admin_grant_path(@grant), notice: notice)
      else
        render :new
      end
    end

    # GET /grants/1
    # GET /grants/1.json
    def show
      # debugger
      @grant = Grant.unscoped.find(params[:id]).decorate

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @grant }
      end
    end

    # GET /grants/1/edit
    def edit
      # debugger
      @grant = GrantFactory.find(params[:id])
    end

    # PUT /grants/1
    # PUT /grants/1.json
    def update
      @grant, notice = GrantFactory.update(params)
      if @grant.errors.any?
        render :edit
      else
        redirect_to [:admin, @grant], notice: notice
      end
    end
  end
end
