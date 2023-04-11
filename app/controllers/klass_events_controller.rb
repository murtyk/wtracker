# frozen_string_literal: true

class KlassEventsController < ApplicationController
  before_action :authenticate_user!

  # GET /klass_events/new
  # GET /klass_events/new.json
  def new
    @klass_event = Klass.find(params[:klass_id]).klass_events.build
    authorize @klass_event

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @klass_event }
    end
  end

  # GET /klass_events/1/edit
  def edit
    @klass_event = find_klass_event
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @klass_event }
    end
  end

  # POST /klass_events
  def create
    @klass_event = create_from_factory
    respond_to do |format|
      if @klass_event.errors.empty?
        format.html { redirect_to @klass_event.klass, notice: notice_created }
        format.js
      else
        format.html { render :new }
      end
    end
  end

  # PUT /klass_events/1
  # PUT /klass_events/1.json
  def update
    @klass_event = find_and_update_from_factory

    respond_to do |format|
      if @klass_event.errors.empty?
        format.html { redirect_to @klass_event.klass, notice: notice_updated }
      else
        format.html { render :edit }
      end
      format.js
    end
  end

  # DELETE /klass_events/1
  # DELETE /klass_events/1.json
  def destroy
    @klass_event = find_klass_event
    @klass = @klass_event.klass.decorate

    @klass_event.destroy
    UserMailer.send_event_invite(@klass_event, current_user, true).deliver_now

    respond_to do |format|
      format.html { redirect_to klass_events_url }
      format.js
      format.json { head :no_content }
    end
  end

  private

  def klass_event_params
    params.require(:klass_event)
          .permit(:event_date, :name, :klass_id, :notes,
                  :start_ampm, :start_time_hr, :start_time_min,
                  :end_ampm, :end_time_hr, :end_time_min,
                  employer_ids: [])
  end

  def find_and_update_from_factory
    ke = find_klass_event
    KlassEventFactory.update_klass_event(ke, klass_event_params, current_user)
  end

  def find_klass_event
    klass_event = KlassEvent.find(params[:id])
    authorize klass_event
    klass_event
  end

  def create_from_factory
    authorize KlassEvent.new
    KlassEventFactory.create(klass_event_params, current_user)
  end

  def notice_created
    'Class event was successfully created.'
  end

  def notice_updated
    'Class event was successfully updated.'
  end
end
