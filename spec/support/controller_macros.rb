module ControllerMacros
  def login_opero_admin
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      # sign_in FactoryBot.create(:admin) # Using factory girl as an example
      sign_in Admin.first # Using factory girl as an example
    end
  end

  def login_user(email = nil)
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      user = User.unscoped.find_by(email: email) if email
      user = User.unscoped.find_by(email: 'ballu@mail.com') unless email
      sign_in user
    end
  end
end
