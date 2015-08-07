class Trainee
  # A trainee has signed in.
  # workflow: 1. update dob and ssn -> edit
  #           2. Resume File -> Perform Portal Action
  class TraineesController < TraineePortalController
    def edit
    end

    def update
      if @trainee.update_attributes(trainee_params)
        perform_portal_action
      else
        render 'edit'
      end
    end

    def portal
      perform_portal_action
    end

    def trainee_params
      tp = params[:trainee].clone
      tp[:dob] = opero_str_to_date(tp[:dob]) if tp[:dob]
      tp
    end
  end
end
