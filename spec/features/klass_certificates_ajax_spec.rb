require 'rails_helper'

describe "Klasses" do
  before :each do
    signin_admin
    create_klasses(1)
  end
  after :each do
    destroy_klasses
    signout
  end

  describe 'ajax in show' do
    it 'add a certifactes', js: true do

      click_link 'new_klass_certificate_link'
      # wait_for_ajax
      fill_in 'klass_certificate_name', with: "Certificate 1"
      fill_in 'klass_certificate_description', with: "Certificate Description"
      click_on 'Add'
      # wait_for_ajax
      expect(page).to have_text 'Certificate 1'
    end

    it 'removes new certifacte form on cancel', js: true do
      click_link 'new_klass_certificate_link'
      # wait_for_ajax
      assert has_field?('klass_certificate_name')
      click_on 'Cancel'
      # wait_for_ajax
      assert has_no_field?('klass_certificate_name')
    end
  end
end
