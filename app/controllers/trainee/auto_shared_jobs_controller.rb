# frozen_string_literal: true

class Trainee
  # trainee can edit/update notes
  # can update status
  class AutoSharedJobsController < TraineePortalController
    before_action :init_auto_shared_job
    def edit
      ::NewRelic::Agent.add_custom_parameters(host: request.host, trainee_id: trainee_id)
    end

    def update
      if params[:status]
        @auto_shared_job.change_status(params[:status].to_i)
        render 'update_status'
        return
      end

      @auto_shared_job.change_notes(params[:auto_shared_job][:notes])
    end

    private

    def init_auto_shared_job
      return unless params[:id].to_i.positive?

      @auto_shared_job = AutoSharedJob.find(params[:id])
    end

    def trainee_id
      current_trainee.id
    end
  end
end
