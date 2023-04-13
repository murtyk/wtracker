# frozen_string_literal: true

# trainees can be added on class page
# class can be added on trainee page
# multiple trainees can be added through near by colleges page
class KlassTraineesController < ApplicationController
  before_action :authenticate_user!

  def ojt_enrolled
    kt = KlassTrainee.find(params[:id])
    trainee = kt.trainee
    oe = trainee.trainee_interactions
                .where(status: 5, termination_date: nil)
                .count.positive?

    render json: oe
  end

  def new
    @klass_trainee,
    @trainees,
    @klasses_collection = KlassTraineeFactory.new(params_for_new)
  end

  # GET /klass_trainees/1/edit
  def edit
    @klass_trainee = KlassTrainee.find(params[:id])
    return unless @klass_trainee.hired?

    @error_message = 'Can not change status of a placed trainee.' \
                     ' Go to trainee page to change placement details'
  end

  def create
    @object = KlassTraineeFactory.add_klass_trainees(params_for_create).decorate
    respond_to do |format|
      if @object.errors.empty?
        format.html { redirect_to @object, notice: 'Trainees Added.' }
      else
        format.html { render :new }
      end
      format.js
    end
  end

  # PUT /klass_trainees/1
  def update
    @klass_trainee = KlassTraineeFactory
                     .update_klass_trainee(params[:id], params_for_update)
  end

  # DELETE /klass_trainees/1
  def destroy
    @klass_trainee = KlassTrainee.find(params[:id]).decorate
    @trainee_page = params[:from]
    @klass_trainee.destroy
  end

  private

  def params_for_new
    params.permit(:klass_id, :trainee_id, :trainee_ids)
  end

  def params_for_create
    params.require(:klass_trainee)
          .permit(:klass_id, :trainee_id, :trainee_ids, trainee_id: [], trainee_ids: [])
  end

  def params_for_update
    params.require(:klass_trainee)
          .permit(:status, :notes, :employer_id, :employer_id,
                  :start_date, :completion_date,
                  :hire_title, :hire_salary, :comment,
                  :ti_status, :uses_trained_skills)
  end
end
