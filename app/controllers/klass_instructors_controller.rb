class KlassInstructorsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @klass = Klass.find(params[:klass_id])
    @klass_instructor = @klass.klass_instructors.build
    @instructors = @klass.instructors_for_selection

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @klass_instructor }
    end
  end

  def create
    @klass_instructor = KlassInstructor.new(params[:klass_instructor])
    @klass_instructor.save
    @klass = @klass_instructor.klass
  end

  # DELETE /klass_instructors/1
  # DELETE /klass_instructors/1.json
  def destroy
    @klass_instructor = KlassInstructor.find(params[:id])
    @klass_instructor.destroy

    respond_to do |format|
      format.html { redirect_to klass_instructors_url }
      format.js
      format.json { head :no_content }
    end
  end
end
