require 'rails_helper'

describe "grants" do

  it "navigator can select one" do

    Account.current_id = 1
    melinda = User.where(email: 'melinda@mail.com').first
    grant = Grant.first
    Grant.current_id = grant.id
    klass = Klass.first
    klass.klass_navigators.create(user_id: melinda.id)

    #create another grant
    grant = Grant.create(name: 'Mega Grant', status: 2, start_date: Date.today,
                         end_date: Date.today + 1.year)

    Grant.current_id = grant.id
    program = grant.programs.create(name: 'Mega Program', description: 'Mega Program')
    college = College.first
    klass = program.klasses.create(name: 'Mega Class', college_id: college.id)
    melinda = User.where(email: 'melinda@mail.com').first
    klass.klass_navigators.create(user_id: melinda.id)

    signin_navigator
    # grant selection page
    select 'Mega Grant', from: 'Change Current Grant To'
    click_on 'Set Grant'

    signout
  end
end
