require 'rails_helper'

describe 'Klasses' do
  before :each do
    signin_admin
    create_klasses(1)
  end
  after :each do
    destroy_klasses
    signout
  end

  describe 'ajax in show' do
    it 'can add and remove navigator', js: true do
      click_link 'new_klass_navigator_link'
      # wait_for_ajax
      select('Melinda Peters', from: 'klass_navigator_user_id')
      click_on 'Add'
      # wait_for_ajax
      expect(page).to have_text 'Melinda Peters'
      klass = get_klasses.first
      klass_navigator = klass.klass_navigators.first
      id = "destroy_klass_navigator_#{klass_navigator.id}_link"
      click_link id
      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      expect(page).to_not have_text 'Melinda Peters'
    end

    it 'removes add navigator form on cancel', js: true do
      click_link 'new_klass_navigator_link'
      # wait_for_ajax
      assert has_field?('klass_navigator_user_id')
      click_on 'Cancel'
      # wait_for_ajax
      assert has_no_field?('klass_navigator_user_id')
    end
  end
end
