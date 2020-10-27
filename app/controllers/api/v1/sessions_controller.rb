class Api::V1::SessionsController < Api::V1::ApiBaseController
  def create
    admin_password = params[:session][:password]
    admin_email = params[:session][:email]
    admin = admin_email.present? && Admin.find_by(email: admin_email)
    if admin.valid_password? admin_password
      sign_in admin, store: false
      admin.generate_authentication_token!
      admin.save
      render json: admin, root: 'admin', status: 200
    else
      render json: { errors: 'Invalid email or password' }, status: 422
    end
  end

  def destroy
    admin = Admin.find_by(auth_token: params[:id])
    admin.generate_authentication_token!
    admin.save
    head 204
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
