# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account_state, :class => 'AccountStates' do
    account nil
    state nil
  end
end
