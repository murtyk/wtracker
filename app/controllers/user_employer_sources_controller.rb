class UserEmployerSourcesController < ApplicationController
  before_filter :authenticate_user!

  def new
    user = User.find(params[:user_id])
    @user_employer_source = user.user_employer_sources.new
    authorize @user_employer_source
  end

  def create
    @user = User.find(params[:user_employer_source][:user_id])
    @user_employer_source = @user.user_employer_sources
                                 .new(employer_source_id:
                                 params[:user_employer_source][:employer_source_id])
    authorize @user_employer_source
    @user_employer_source.save
  end

  def destroy
    @user_employer_source = UserEmployerSource.find(params[:id])
    authorize @user_employer_source
    @user_employer_source.destroy
  end
end
