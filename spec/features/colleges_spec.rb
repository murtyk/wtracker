require 'rails_helper'

describe "Colleges" do

  describe "all rest actions except destroy" do
    before(:each) do
      signin_director
    end
    it "lists" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      VCR.use_cassette('colleges') do
        click_on 'Colleges'
        # href_link('colleges').click
        account = Account.first
        Account.current_id = account.id
        colleges = College.all
        colleges.each do |college|
          expect(page).to have_text(college.name)
        end
      end

    end
    it "shows" do
      VCR.use_cassette('colleges') do
        href_link('colleges').click
        href_link('colleges/1').click

        account = Account.first
        Account.current_id = account.id
        college = College.find(1)
        expect(page).to have_text(college.name)
      end
    end
    it "can create and update" do
      VCR.use_cassette('colleges') do
        href_link('colleges').click
        href_link('colleges/new').click
        fill_in 'Name', with: 'Test College'
        fill_in 'Street', with: '10 Mozart CT'
        fill_in 'City', with: 'East Windsor'
        select('NJ', from: 'State')
        fill_in 'Zip', with: '08520'

        click_button 'Add'
        expect(page).to have_text 'Test College'

        href_link('colleges').click
        account = Account.first
        Account.current_id = account.id
        college = College.where(name: 'Test College').first
        href_link('colleges/' + college.id.to_s).click

        expect(page).to have_text college.name

        href_link('colleges').click
        account = Account.first
        Account.current_id = account.id
        college = College.where(name: 'Test College').first

        href_link('colleges/' + college.id.to_s + "/edit").click

        fill_in 'Name', with: 'Changed Name'
        click_button 'Update'
        expect(page).to have_text 'Changed Name'
      end
    end

  end
end
