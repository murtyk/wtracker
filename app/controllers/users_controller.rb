class UsersController < ApplicationController
  before_filter :authenticate_user!

  def online
    @users = current_user.online_users
    respond_to do |format|
      format.json { render json: @users }
    end
  end

  def edit_password
    @user = current_user
  end

  def update_password
    @user = current_user
    if @user.update_attributes(params[:user])
      # Sign in the user by passing validation in case his password changed
      sign_in @user, bypass: true
      flash[:notice] = 'Password successfully updated'
      redirect_to dashboards_path
    else
      render 'edit_password'
    end
  end

  def preferences
  end

  def update_preferences
    current_user.copy_job_shares = params[:user]
  end

  def show
    @user = User.find(params[:id]).decorate
    authorize @user
  end

  def index
    @users = current_account.users.order(:first, :last).decorate
    authorize User
  end

  def new
    @user = current_user.account.users.build
    authorize @user
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user

    if @user.update_and_assign_role(params[:user])
      redirect_to @user, notice: 'user was successfully updated.'
    else
      render :edit
    end
  end

  def create
    @user = User.new(params[:user]
                     .merge(password_confirmation: params[:user][:password]))
    authorize @user

    if valid_password && @user.save
      redirect_to users_path, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  private

  def valid_password
    return true if params[:user][:password].length >= 8
    @user.errors.add(:password, 'required. minimum 8 characters.')
    false
  end
end
