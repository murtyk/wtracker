class KlassNavigatorsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @klass = Klass.find(params[:klass_id])
    @klass_navigator = @klass.klass_navigators.build
    @navigators = @klass.navigators_for_selection

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @klass_navigator }
    end
  end

  def create
    @klass_navigator = KlassNavigator.new(params[:klass_navigator])
    @klass_navigator.save
    @klass = @klass_navigator.klass
  end

  # DELETE /klass_navigators/1
  # DELETE /klass_navigators/1.json
  def destroy
    @klass_navigator = KlassNavigator.find(params[:id])
    @klass_navigator.destroy

    respond_to do |format|
      format.html { redirect_to klass_navigators_url }
      format.js
      format.json { head :no_content }
    end
  end
end
