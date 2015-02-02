class KlassEventsController < ApplicationController
  before_filter :authenticate_user!

  # GET /klass_events/1
  # GET /klass_events/1.json
  # def show
  #   @klass_event = KlassEvent.find(params[:id])
  #   authorize @klass_event

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @klass_event }
  #   end
  # end

  # GET /klass_events/new
  # GET /klass_events/new.json
  def new
    klass = Klass.find(params[:klass_id])
    @klass_event = klass.klass_events.build
    logger.info { "[#{current_user.name}] [klass_event new]" }
    authorize @klass_event

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @klass_event }
    end
  end

  # GET /klass_events/1/edit
  def edit
    @klass_event = KlassEvent.find(params[:id])
    # debugger
    authorize @klass_event
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @klass_event }
    end
  end

  # POST /klass_events
  # POST /klass_events.json
  def create
    authorize Klass.find(params[:klass_id]).klass_events.new
    @klass_event = KlassEventFactory.create(params, current_user)

    respond_to do |format|
      if @klass_event.errors.empty?
        notice = 'Class event was successfully created.'
        format.html { redirect_to @klass_event.klass, notice: notice }
        format.js
      else
        format.html { render :new }
      end
    end
  end

  # PUT /klass_events/1
  # PUT /klass_events/1.json
  def update
    authorize KlassEvent.find(params[:id])
    @klass_event = KlassEventFactory.update_klass_event(params, current_user)
    klass = @klass_event.klass

    respond_to do |format|
      if @klass_event.errors.count == 0
        format.html { redirect_to klass, notice: 'Class event was successfully updated.' }
        format.js
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  # DELETE /klass_events/1
  # DELETE /klass_events/1.json
  def destroy
    @klass_event = KlassEvent.find(params[:id])
    @klass = @klass_event.klass.decorate
    authorize @klass_event

    @klass_event.destroy

    respond_to do |format|
      format.html { redirect_to klass_events_url }
      format.js
      format.json { head :no_content }
    end
  end
end
