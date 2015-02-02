class KlassTraineesController < ApplicationController
  before_filter :authenticate_user!

  # GET /klass_trainees/new
  def new
    if params[:trainee_ids]
      @trainees = Trainee.where(id: params[:trainee_ids].split(','))
      klasses  = Klass.where('start_date > ?', Date.today).order(:start_date)
      @klasses_collection = klasses.map do |k|
        [k.to_label + '-' + k.start_date.to_s + " (#{k.trainees.count})", k.id]
      end
    elsif params[:trainee_id]
      @trainee = Trainee.find params[:trainee_id]
      @klass_trainee = @trainee.klass_trainees.build
    else
      @klass = Klass.find(params[:klass_id])
      @klass_trainee = @klass.klass_trainees.build
    end
  end

  # GET /klass_trainees/1/edit
  def edit
    @klass_trainee = KlassTrainee.find(params[:id])
    @from_page = params[:from].to_i
  end

  # 3 ways to come here
  # Trainee Page:   params will have :trainee_id
  #        @object should be Trainee
  # Klass Page: params will have trainee_ids as array
  #        @object should be Klass
  # Near By Colleges ->  new.html -> trainee_ids as string
  #        @object should be Klass
  def create
    @object = KlassTraineeFactory.add_klass_trainees(params).decorate
    respond_to do |format|
      if @object.errors.empty?
        format.html { redirect_to @object, notice: 'Trainees Added.' }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  # PUT /klass_trainees/1
  def update
    @klass_trainee = KlassTraineeFactory.update_klass_trainee(params)
  end

  # DELETE /klass_trainees/1
  def destroy
    @klass_trainee = KlassTrainee.find(params[:id]).decorate
    @trainee_page = params[:from]
    @klass_trainee.destroy
  end
end
