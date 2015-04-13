require 'rails_helper'

describe 'Grant Admin' do
  before :each do
    Account.current_id = Account.find_by(subdomain: 'apple')
    Grant.current_id = Grant.first.id
    user = create(:user)
    @user_email = user.email
    sign_in_user('apple', @user_email)

    @klasses = Klass.all
  end
  it 'Can access all classes in grant' do
    @klasses.each do |klass|
      expect(page).to have_text klass.name
      expect(page).to have_xpath("//a[@href='/klasses/#{klass.id}']")
    end
  end
end
