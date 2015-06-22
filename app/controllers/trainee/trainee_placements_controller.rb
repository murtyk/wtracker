class Trainee
  # to enter placement information
  class TraineePlacementsController < TraineePortalController
    def new
      @trainee_placement = @trainee.trainee_placements.new
    end

    def create
      params[:trainee_placement].delete(:trainee_id)
      @trainee_placement = @trainee.trainee_placements.new
      if @trainee_placement.update(params[:trainee_placement])
        flash[:notice] = 'New Job Information Saved.'
        redirect_to [:trainee, @trainee.job_search_profile]
      else
        render 'new'
      end
    end

    def index
      @trainee_placements = @trainee.trainee_placements
    end
  end
end
