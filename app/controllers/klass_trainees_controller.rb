# trainees can be added on class page
# class can be added on trainee page
# multiple trainees can be added through near by colleges page
class KlassTraineesController < ApplicationController
  before_filter :authenticate_user!

  def ojt_enrolled
    kt = KlassTrainee.find(params[:id])
    trainee = kt.trainee
    oe = trainee.trainee_interactions
         .where(status: 5, termination_date: nil)
         .count > 0

    render json: oe
  end

  def new
    @klass_trainee,
    @trainees,
    @klasses_collection = KlassTraineeFactory.new(params)
  end

  # GET /klass_trainees/1/edit
  def edit
    @klass_trainee = KlassTrainee.find(params[:id])
    return unless @klass_trainee.hired?
    @error_message = 'Can not change status of a placed trainee.' \
                     ' Go to trainee page to change placement details'
  end

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
