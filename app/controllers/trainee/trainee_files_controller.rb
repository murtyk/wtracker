class Trainee
  # resume and unemp proof docs for workflow
  # and any other files
  class TraineeFilesController < TraineePortalController
    def new
      init_required_file_data
      @trainee_file = current_trainee.trainee_files.new(notes: params[:notes])
    end

    def create
      saved,
      error_message,
      @trainee_file = TraineeFactory.add_trainee_file(params[:trainee_file],
                                                      current_trainee)

      return action_after_create if saved

      @trainee_file ||= current_trainee.trainee_files.new(params[:trainee_file])
      @trainee_file.errors.add(:file, error_message)
      render 'new'
    end

    def index
      @trainee_files = current_trainee.trainee_files.to_a
      @trainee_file = current_trainee.trainee_files.new
    end

    private

    def action_after_create
      if portal_action?
        perform_portal_action
      else
        flash[:notice] = 'Document uploaded successfully.'
        redirect_to trainee_trainee_files_path
      end
    end

    def portal_action?
      @trainee.trainee_files.count < 3
    end

    def init_required_file_data
      return unless params[:notes]
      @required_file = true
      @caption = 'your recent resume' if params[:notes] == 'Resume'
      @caption = 'unemployment proof' if params[:notes] == 'Unemployment Proof'
      @caption = "Please upload #{@caption} document in MS Word or PDF format"
    end
  end
end
