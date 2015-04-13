module ApplicantsHelper
  def build_applicant_data(acceptable = true)
    os = OpenStruct.new
    os.first_name    = 'Adaline'
    os.last_name     = 'Schuster'
    os.email         = 'adaline_schuster@shields.biz'

    os.name = os.first_name + ' ' + os.last_name

    os.address_line1 = '120 Wood Ave S'
    os.address_city  = 'Iselin'
    os.address_zip   = '08830'
    os.county        = 'Middlesex'

    os.mobile_phone_no = '626 656 2323'
    os.sector          = 'telecom'
    os.veteran         = 'No'
    os.legal_status    = 'Resident Alien'
    os.gender          = 'Male'
    os.race            = 'Asian'

    os.employment_status = acceptable ? 'Employed Part Time' : 'Employed Full Time'

    os.last_employed_on    = '10/17/2014'
    os.last_employer_name  = 'ABC Inc'
    os.last_employer_line1 = '1 Metroplex Dr'
    os.last_employer_city  =  'Edison'
    os.last_employer_state = 'NJ'
    os.last_employer_zip   = '08817'

    os.last_employer_manager_name     = 'John Smith'
    os.last_employer_manager_phone_no = '7773332222'

    os.last_wages = '100K'
    os.last_job_title = 'Sr. Developer'
    os.salary_expected = '75-85K'

    os.education_level    = 'GED'
    os.unemployment_proof = 'Letter from Unemployment'
    os.special_service    = 'Child Care'
    os.transportation     = 'Yes'
    os.computer_access    = 'No'
    os.source             = 'One Stop'

    os.resume =  'I am an excellent software developer with 10 years' \
                  ' of experience in java, ajax, xml, oracle'
    os.humanizer_answer = '4'
    os
  end

  def fill_applicant_form(a, re_apply = false)
    fill_in 'applicant_first_name',      with: a.first_name
    fill_in 'applicant_last_name',       with: a.last_name
    fill_in 'applicant_address_line1',   with: a.address_line1
    fill_in 'applicant_address_city',    with: a.address_city
    fill_in 'applicant_address_zip',     with: a.address_zip
    select a.county,                    from: 'applicant_county_id'

    unless re_apply
      fill_in 'applicant_email',           with: a.email
      fill_in 'applicant_email_confirmation', with: a.email
    end

    fill_in 'applicant_mobile_phone_no', with: a.mobile_phone_no
    select a.sector,             from: 'applicant_sector_id'

    select a.veteran,            from: 'applicant_veteran'
    select a.legal_status,       from: 'applicant_legal_status'
    select a.gender,             from: 'applicant_gender'
    select a.race,               from: 'applicant_race_id'

    select a.employment_status,  from: 'applicant_current_employment_status'

    fill_in 'applicant_last_employed_on',    with: a.last_employed_on
    fill_in 'applicant_last_employer_name',  with: a.last_employer_name
    fill_in 'applicant_last_employer_line1', with: a.last_employer_line1
    fill_in 'applicant_last_employer_city',  with: a.last_employer_city
    select a.last_employer_state,   from: 'applicant_last_employer_state'
    fill_in 'applicant_last_employer_zip',   with: a.last_employer_zip

    fill_in 'applicant_last_employer_manager_name', with: a.last_employer_manager_name
    fill_in 'applicant_last_employer_manager_phone_no',  with: a.last_employer_manager_phone_no

    fill_in 'applicant_last_wages',         with: a.last_wages
    fill_in 'applicant_last_job_title',     with: a.last_job_title
    fill_in 'applicant_salary_expected',    with: a.salary_expected
    select a.education_level,               from: 'applicant_education_level'
    select a.unemployment_proof,            from: 'applicant_unemployment_proof'
    select a.special_service,               from: 'applicant[special_service_ids][]'
    select a.transportation,                from: 'applicant_transportation'
    select a.computer_access,               from: 'applicant_computer_access'
    select a.source,                        from: 'applicant_source'

    # use the below when ready to test js: true
    # select 'Other, please specify',             from: 'applicant_reference'
    # prompt = page.driver.browser.switch_to.alert
    # prompt.send_keys('This is my reference')
    # prompt.accept

    fill_in 'applicant_resume',  with: a.resume
    fill_in 'applicant_humanizer_answer', with: a.humanizer_answer

    check 'applicant_signature'
  end
end
