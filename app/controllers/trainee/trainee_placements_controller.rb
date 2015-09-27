class Trainee
  # to enter placement information
  class TraineePlacementsController < TraineePortalController
    def new
      @trainee_placement = @trainee.trainee_placements.new
    end

    def create
      @trainee_placement = @trainee.trainee_placements.new
      if @trainee_placement.update(tp_params)
        flash[:notice] = 'New Job Information Saved.'
        redirect_to [:trainee, @trainee.job_search_profile]
      else
        render 'new'
      end
    end

    def index
      @trainee_placements = @trainee.trainee_placements
    end

    def tp_params
      tp = params.clone
      tp[:trainee_placement].delete(:trainee_id)
      tp.require(:trainee_placement)
        .permit(:placement_type,
                :company_name,
                :address_line1,
                :city,
                :state,
                :zip,
                :phone_no,
                :salary,
                :job_title,
                :start_date)
    end
  end
end
