require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user_attributes = FactoryGirl.attributes_for(:user)
    @invalid_attributes = FactoryGirl.attributes_for(:user, email: '')

    Account.current_id = 1
    @account = Account.find 1
    @user = @account.users.build(@user_attributes)
  end

  subject { @user }

  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:password) }
  it { is_expected.to respond_to(:password_confirmation) }

  it { expect(@account.users.create(@user_attributes)).to be_valid }
  it { expect(@account.users.create(@invalid_attributes)).not_to be_valid }

  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_uniqueness_of(:email) }
  it { is_expected.to validate_confirmation_of(:password) }
  it { is_expected.to allow_value('example@domain.com').for(:email) }
end
