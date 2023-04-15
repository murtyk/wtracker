# frozen_string_literal: true

class Trainee
  # A trainee has signed in.
  # workflow: 1. update dob and ssn -> edit
  #           2. Resume File -> Perform Portal Action
  class TraineesController < TraineePortalController
    def edit; end

    def update
      if @trainee.update(trainee_params)
        perform_portal_action
      else
        render 'edit'
      end
    end

    def portal
      perform_portal_action
    end

    def trainee_params
      dob = params[:trainee][:dob]
      return params.require(:trainee).permit(:dob, :trainee_id) unless dob

      tp = params.clone
      tp[:trainee][:dob] = opero_str_to_date(dob)
      tp.require(:trainee).permit(:dob, :trainee_id)
    end
  end
end
