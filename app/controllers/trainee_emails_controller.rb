# an user typically sends emails to 1 or more trainees in a class
class TraineeEmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trainee_email, only: [:show, :destroy]

  # GET /trainee_emails
  def index
    @trainee_emails = sent_emails.paginate(page: params[:page], per_page: 15)
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
    @trainee_email = EmailFactory.create_trainee_email(trainee_email_params,
                                                       current_user)

    if @trainee_email.errors.empty?
      notice = 'email was successfully scheduled for delivery.'
      redirect_to @trainee_email, notice: notice
    else
      render :new
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
    te_params = params.require(:trainee_email)
                .permit(:account_id, :user_id, :klass_id, :trainee_names,
                        :subject, :content,
                        trainee_ids: [])
    te_params[:trainee_ids] ||= params[:trainee_ids]
    te_params[:trainee_ids] ||= params[:trainee_email][:trainee_ids]
    te_params
  end

  def sent_emails
    if current_user.admin_access?
      klass_ids = current_grant.klasses.pluck(:id) + [0]
      TraineeEmail.includes(:user)
        .where(klass_id: klass_ids)
        .order('created_at desc')
    else
      current_user.trainee_emails.order('created_at desc')
    end
  end
end
