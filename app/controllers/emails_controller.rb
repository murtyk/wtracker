require 'open-uri'

class EmailsController < ApplicationController
  before_filter :authenticate_user!

  def index
    if current_user.admin_access?
      @emails = Email.includes(:user).order('created_at desc').to_a
    else
      @emails = current_user.emails.order('created_at desc').to_a
    end
    @emails = @emails.paginate(page: params[:page], per_page: 15)
  end

  def show
    @email = Email.find(params[:id])
  end

  def new_attachment
    @number = params[:number]
  end

  def new
    @email = current_user.emails.new
    @email.attachments.new
    logger.info { "[#{current_user.name}] [email new]" }

    @contacts = []

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @email }
    end
  end

  def create
    @email = EmailFactory.create_email(params, current_user)

    respond_to do |format|
      if @email.errors.count == 0
        notice = 'email was successfully scheduled for delivery.'
        format.html { redirect_to @email, notice: notice }
      else
        format.html { render :new }
      end
    end
  end

  def destroy
    @email = Email.find(params[:id])

    @email.destroy

    respond_to do |format|
      format.html { redirect_to emails_url }
      format.js
      format.json { head :no_content }
    end
  end
end
