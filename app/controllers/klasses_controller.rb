# A grant has many programs and a program can have many Klasses
# Some Klass events are created by default when a class is created
# trainees are assigned to a class
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
      format.json { render json: @klass.trainees_with_email }
    end
  end

  def visits_calendar
    @klass = Klass.find(params[:id]).decorate

    respond_to do |format|
      format.html
      format.xls
    end
  end

  # GET /klasses
  # GET /klasses.json
  def index
    @klasses_service = KlassesService.new(current_user)

    respond_to do |format|
      format.html { @programs_data = @klasses_service.metrics }
      format.js  { send_klasses_list_file_by_email }
      format.xls { send_klasses_list_file }
    end
  end

  # GET /klasses/1
  # GET /klasses/1.json
  def show
    @klass = Klass
             .includes(:klass_titles,
                       klass_trainees: { trainee: [:trainee_notes,
                                                   { hired_interaction: :employer }] })
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
    program = Program.find params[:program_id]
    @klass = KlassFactory.new_klass(program)
    authorize @klass

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @klass }
    end
  end

  # GET /klasses/1/edit
  def edit
    @klass = Klass.find(params[:id])
    authorize @klass
  end

  # POST /klasses
  # POST /klasses.json
  def create
    # debugger
    @klass = KlassFactory.build_klass(klass_params)
    authorize @klass

    respond_to do |format|
      if @klass.save
        format.html { redirect_to @klass, notice: 'Class was successfully created.' }
        format.json { render json: @klass, status: :created, location: @klass }
      else
        format.html { render :new }
        format.json { render json: @klass.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /klasses/1
  # PUT /klasses/1.json
  def update
    klass = Klass.find(params[:id])
    authorize klass

    @klass = KlassFactory.update_klass(params[:id], klass_params)

    if @klass.errors.any?
      render :edit
      return
    end

    redirect_to @klass, notice: 'Class was successfully updated.'
  end

  # DELETE /klasses/1
  # DELETE /klasses/1.json
  def destroy
    @klass = Klass.find(params[:id])
    logger.info { "[#{current_user.name}] [klass destroy] [klass_id: #{@klass.id}]" }
    authorize @klass
    @klass.destroy
  end

  private

  def klass_params
    params.require(:klass)
      .permit(:program_id, :name, :credits, :description, :klass_category_id,
              :end_date, :start_date, :training_hours, :college_id,
              klass_schedules_attributes: [:id, :dayoftheweek, :scheduled,
                                           :start_ampm, :start_time_hr, :start_time_min,
                                           :end_ampm, :end_time_hr, :end_time_min])
  end

  def send_klasses_list_file
    @klasses_service.build_document
    send_file @klasses_service.file_path, type: 'application/vnd.ms-excel',
                              filename: @klasses_service.file_name,
                              stream: false
  end

  def send_klasses_list_file_by_email
    @klasses_service.delay.send_results
    Rails.logger.info "#{current_user.name} has requested Klasses List file by email"
  end
end
