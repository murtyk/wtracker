include AjaxHelper
# for generation and destruction of employers
module EmployersHelper
  def create_employers(n = 1, address = false)
    seq = 0
    street_number = 100
    VCR.use_cassette('employers_helper') do
      n.times do
        seq += 1
        visit '/employers/new'
        fill_in 'Name', with: "Company#{seq}"
        select random_sector_name, from: 'Sectors'
        if address
          street_number += 1
          fill_address(street_number)
        end
        click_button 'Save'
      end
    end

    get_employer_ids
  end

  def random_sector_name
    Sector.unscoped.order('RANDOM()').first.name
  end

  def fill_address(street_number)
    fill_in 'Street', with: "#{street_number} College Rd E"
    fill_in 'City', with: 'Princeton'
    select 'NJ', from: 'State'
    fill_in 'Zip', with: '08540'
  end

  def destroy_employers
    allow_any_instance_of(EmployerPolicy).to receive('destroy?')
      .and_return(true)

    employers_count = get_employer_ids.count

    visit '/employers'

    fill_in 'filters_name', with: 'Company'
    click_on 'Find'
    sleep 0.2

    employers_count.times { destroy_one_employer }
  end

  def destroy_one_employer
    find('a.btn-danger', match: :first).click
    page.driver.browser.switch_to.alert.accept
    wait_for_ajax
  end

  def get_employer_ids
    Account.current_id = 1
    Employer.where('name ilike ?', 'Company%').pluck(:id)
  end

  def get_employer_notes_ids
    employer_ids = get_employer_ids
    EmployerNote.where(employer_id: employer_ids).pluck(:id).sort
  end

  def get_employer_notes
    employer_ids = get_employer_ids
    EmployerNote.where(employer_id: employer_ids).order('created_at desc')
  end

  def get_employers
    Account.current_id = 1
    Grant.current_id = 1
    Employer.where('name ilike ?', 'Company%')
  end

  def create_contacts(employers, n = 1)
    seq = 0
    employers.each do |employer|
      visit employer_path(employer)
      n.times do
        seq += 1
        click_link new_link_id('contact')
        wait_for_ajax
        fill_in 'contact_first', with: "Client#{seq}"
        fill_in 'contact_last', with: "Client#{seq}"
        fill_in 'contact_title', with: 'Client'
        fill_in 'contact_email', with: "client#{seq}@mail.com"
        click_on 'Add'
        wait_for_ajax
      end
    end
  end
end
