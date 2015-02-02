class KlassesController < ApplicationController
  before_filter :authenticate_user!

  def events
    @klass = Klass.find(params[:id])
    # authorize @klass
    selection_list = @klass.klass_events.map do |ke|
      { id: ke.id, label: ke.selection_name }
    end
    respond_to do |format|
      # format.json { render json: @klass.klass_events }
      format.json { render json: selection_list }
    end
  end

  def trainees
    @klass = Klass.find(params[:id])
    authorize @klass
    current_user.last_klass_selected = @klass.id
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @klass.trainees }
    end
  end

  def trainees_with_email
    @klass = Klass.find(params[:id])
    authorize @klass
    current_user.last_klass_selected = @klass.id
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @klass.trainees }
    end
  end

  def visits_calendar
    @klass = Klass.find(params[:id])

    respond_to do |format|
      format.html
      format.xls
    end
  end

  # GET /klasses
  # GET /klasses.json
  def index
    @programs = Program.includes(klasses: :college).load
  end

  # GET /klasses/1
  # GET /klasses/1.json
  def show
    @klass = Klass.includes(:klass_titles,
                            klass_trainees: :trainee,
                            klass_events: { klass_interactions: :employer })
                  .find(params[:id])
                  .decorate
    authorize @klass

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @klass }
    end
  end

  # GET /klasses/new
  # GET /klasses/new.json
  def new
    logger.info { "[#{current_user.name}] [klass new]" }

    @klass = KlassFactory.new_klass(params)
    authorize @klass

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @klass }
    end
  end

  # GET /klasses/1/edit
  def edit
    @klass = Klass.find(params[:id])
    logger.info { "[#{current_user.name}] [klass edit] [klass_id: #{@klass.id}]" }
    authorize @klass
  end

  # POST /klasses
  # POST /klasses.json
  def create
    # debugger
    @klass = KlassFactory.new_klass(params)
    logger.info { "[#{current_user.name}] [klass create] [name: #{@klass.name}]" }
    authorize @klass

    respond_to do |format|
      if @klass.save
        format.html { redirect_to @klass, notice: 'Class was successfully created.' }
        format.json { render json: @klass, status: :created, location: @klass }
      else
        # debugger
        format.html { render :new }
        format.json { render json: @klass.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /klasses/1
  # PUT /klasses/1.json
  def update
    klass = Klass.find(params[:id])
    logger.info { "[#{current_user.name}] [klass update] [klass_id: #{klass.id}]" }
    authorize klass

    respond_to do |format|
      @klass = KlassFactory.update_klass(params)
      if @klass.errors.count == 0
        format.html { redirect_to @klass, notice: 'Class was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /klasses/1
  # DELETE /klasses/1.json
  def destroy
    @klass = Klass.find(params[:id])
    logger.info { "[#{current_user.name}] [klass destroy] [klass_id: #{@klass.id}]" }
    authorize @klass
    @klass.destroy

    respond_to do |format|
      format.html { redirect_to klasses_url }
      format.js
      format.json { head :no_content }
    end
  end
end
