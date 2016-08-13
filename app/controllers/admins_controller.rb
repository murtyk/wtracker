class AdminsController < ApplicationController
  before_filter :authenticate_admin!

  def observe
    sign_in(:user, User.find(params[:id]), { :bypass => true })
    redirect_to root_url # or user_root_url
  end

  def end_observe
    sign_out(:user)
    redirect_to "/admin/users" # or user_root_url
  end
end
