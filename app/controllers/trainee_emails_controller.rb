class TraineeEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trainee_email, only: [:show, :update, :destroy]

  # GET /trainee_emails
  def index
    klass_ids = current_grant.klasses.pluck(:id) + [0]
    @trainee_emails = TraineeEmail.includes(:user)
                                  .where(klass_id: klass_ids)
                                  .order('created_at desc')
    @trainee_emails = @trainee_emails.to_a.paginate(page: params[:page], per_page: 15)
  end

  # GET /trainee_emails/1
  def show
  end

  # GET /trainee_emails/new
  def new
    @trainee_email = current_user.trainee_emails.new
  end

  # POST /trainee_emails
  def create
    @trainee_email = EmailFactory.create_trainee_email(params, current_user)

    respond_to do |format|
      if @trainee_email.errors.count == 0
        notice = 'email was successfully scheduled for delivery.'
        format.html { redirect_to @trainee_email, notice: notice }
      else
        format.html { render :new }
      end
    end
  end

  # DELETE /trainee_emails/1
  def destroy
    @trainee_email.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_trainee_email
    @trainee_email = TraineeEmail.find(params[:id])
  end

    # Only allow a trusted parameter "white list" through.
  def trainee_email_params
    params.require(:trainee_email).permit(:account_id, :user_id, :klass_id,
                                          :trainee_names, :trainee_ids,
                                          :subject, :content)
  end
end
