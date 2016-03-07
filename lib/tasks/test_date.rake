namespace :testprep do

  # for running parallel tests, do the following
  # rake parallel:drop
  # rake parallel:create
  # rake parallel:prepare
  # RAILS_ENV=test parallel_test -e "rake testprep:load_data"
  # rake parallel:spec[3]

  desc <<-DESC
    recreates test db and loads test data.
    Run using the command 'rake testprep:refresh_db RAILS_ENV=test'
  DESC
  task refresh_db: :environment do
    refresh_test_db if Rails.env.test?
  end

  def refresh_test_db
    puts 'recreating test database'
    Rake::Task['db:test:load'].invoke
    load_data
  end

  desc <<-DESC
    recreates test db and loads test data.
    Run using the command 'rake testprep:load_data RAILS_ENV=test'
  DESC
  task load_data: :environment do
    load_data if Rails.env.test?
  end

  def load_data
    puts 'loading test data'
    set_up
    create_global_reference_data
    create_opero_admin

    set_up_www_account
    set_up_brookdale_account
    set_up_njit_account
    set_up_apple_account
    set_up_operoapi_account
  end

  def set_up
    WebMock.allow_net_connect!
    Geocoder.config[:timeout] = 10
    ActionMailer::Base.default_url_options = { host: 'localhost:3000' }
  end

  def create_global_reference_data
    create_sectors
    create_races
    create_education_levels
    create_states
    create_cities
  end

  def create_opero_admin
    pwd = 'adminpassword'
    Admin.create(email: 'admin@opero.com', password: pwd, password_confirmation: pwd, auth_token: nil)
  end

  def set_up_operoapi_account
    create_account('Opero API', 'for opero api', 1, 1, 'operoapi')
  end

  def set_up_www_account
    account = create_account('PAWF Org', 'Consortium of community colleges of PA',
                             1, 1, 'www', 'alamo.png')
    account.states << de_state

    # in console, we changed subdomain to 'www' to facilitate testing
    college1 = create_college('Bucks county community college', '275 Swamp Rd',
                              'Newtown', 'PA', '18940', 40.24, -74.9671)
    create_college('Northampton Community College', '3835 Green Pond Rd',
                   'Bethlehem', 'PA', '18020', 40.673, -75.323)

    grant = create_grant('Big Grant', 'Jan 1, 2012', 'Dec 31, 2015', 2, 1000, 50_000_000)

    create_user('Sher',    'Khan',    'Philly',  1, 1, 'sher@mail.com')
    create_user('Ballu',   'Bear',    'Philly',  1, 2, 'ballu@mail.com')
    create_user('Melinda', 'Peters',  'Camden',  1, 3, 'melinda@mail.com')
    create_user('Jeffrey', 'Archer',  'Camden',  1, 3, 'jeffrey@mail.com')
    create_user('Ryan',    'Bates',   'Camden',  1, 4, 'ryan@mail.com')
    create_user('Eric',    'Clapton', 'Trenton', 1, 4, 'eric@mail.com')

    grant.assessments_include_score = '1'
    grant.assessments_include_pass = '1'
    grant.save

    create_assessments

    p11  = create_program('Big program 1', 'description of program11',
                          manufacturing.id, 400)
    c111 = create_klass(p11, 'CNC 101', '', 'June 27, 2012',  'Aug 17, 2012',
                        3, 272, college1.id)

    address = ['10 Copland', 'East Windsor', 'NJ', '08520', 40.25, -74.54]
    create_trainee('Paul', 'Harris', 'paul@mail.com', address, c111)

    address = ['10 Mozart', 'East Windsor', 'NJ', '08520', 40.25, -74.54]
    create_trainee('Tom', 'Cruise', 'tom@mail.com', address, c111)

    address = ['5 Mozart', 'East Windsor', 'NJ', '08520', 40.25, -74.54]
    create_trainee('Jessica', 'Lang', 'jessica@mail.com', address)

    create_program('Big program 2', 'description of program12', transport.id, 600)

    address = ['100 South Main Street', 'Jersey Shore', 'PA', '17740', 41.2025, -77.2535]
    emp1 = create_employer('Wawa', address)

    emp1.sectors << manufacturing
    emp1.contacts.create!(email: 'johnny@mail.com', first: 'Johnny', last: 'Darko')

    address = ['1 Metroplex Dr', 'Edison', 'NJ', '08817', 40.5230, -74.4135]
    emp2 = create_employer('Trigyn', address)
    emp2.contacts.create!(email: 'mason@mail.com', first: 'Mason', last: 'Saari')

    emp2.sectors << manufacturing
  end

  def set_up_brookdale_account
    create_account('Brookdale', 'Brookdale Community College', 2, 1, 'brookdale')

    college = create_college('Brookdale Lincroft', '765 Newman Springs Rd',
                             'Middletown', 'NJ', '07738', 40.3279, -74.1334)

    create_grant('No Grant', 'Jan 1, 2012', 'Dec 31, 2015', 2, 0, 0)
    create_user('Marie',   'Lucier-Woodruff', 'Middletown', 1, 1, 'marie@mail.com')
    create_user('Michele', 'Risley',          'Middletown', 1, 2, 'michele@mail.com')

    create_assessments

    p11  = create_program('Program 1', 'description of program 1', manufacturing.id, 400)
    create_klass(p11, 'CNC 101', '', 'March 1, 2014', 'Aug 17, 2015', 3, 272, college.id)
    create_funding_sources
  end

  def set_up_njit_account
    account = create_account('NJIT', 'New Jersey Institute of Technology', 1, 1, 'njit')

    # in console, we changed subdomain to 'www' to facilitate testing
    address = { line1: '765 Newman Springs Rd', city: 'Middletown', state: 'NJ',
                zip: '07738', latitude: 40.3279, longitude: -74.1334 }
    college = College.create!(name: 'Newark Campus', address_attributes: address)

    grant = create_grant('AutoGrant', 'Jan 1, 2012', 'Dec 31, 2015', 2, 0, 0,
                         auto_job_leads: true)

    create_user('Marie', 'Lucier-Woodruff', 'Middletown', 1, 1, 'njit@mail.com')

    create_assessments

    jl = grant.build_profile_request_subject(account_id: account.id)
    jl.content = 'Welcome to the OPERO Application for upSKILL students'
    jl.save

    jl = grant.build_profile_request_content(account_id: account.id)
    jl.content =  "Please enter your job search profile.
                   Please contact $DIRECTOR$ if you have any questions."
    jl.save

    jl = grant.build_job_leads_subject(account_id: account.id)
    jl.content = 'OPERO has identified new job postings requiring your skills'
    jl.save

    jl = grant.build_job_leads_content(account_id: account.id)
    jl.content = "Good Morning $TRAINEEFIRSTNAME$,
                  Here are the recent job postings that match your profile.
                  $JOBLEADS$
                  click here $VIEWJOBSLINK$ to review and apply for jobs.
                  Click here $OPTOUTLINK$ to opt out from these leads."
    jl.save

    jl = grant.build_optout_message_one(account_id: account.id)
    jl.content = 'CONGRATULATIONS!  We wish you the best of luck in your position.'
    jl.save

    jl = grant.build_optout_message_two(account_id: account.id)
    jl.content = "Thank you for your participation in upSKILL.
                  Good luck in your future job searches."
    jl.save

    jl = grant.build_optout_message_three(account_id: account.id)
    jl.content = "Thank you for your participation in upSKILL.
                  Good luck in your future job searches."
    jl.save

    program = create_program('AutoProgram ', 'description of program 1',
                             manufacturing.id, 400)
    klass = create_klass(program, 'Auto Class', '', 'March 1, 2014', 'Aug 17, 2015', 3,
                         272, college.id)

    klass.trainees << Trainee.create(first: 'first', last: 'last', email: 'name@mail.com')

  end

  def set_up_apple_account
    account = create_account('NJWF H1B', 'NJWF H1B Grant Account', 1, 1, 'apple')
    account.states << nj_state

    grant = create_grant('Right To Work', 'Jan 1, 2014', 'Dec 31, 2016',
                         2, 0, 0, trainee_applications: true)

    aid = { account_id: grant.account_id }

    jl = grant.build_job_leads_subject(aid)
    jl.content = 'TAPO has identified new job postings requiring your skills'
    jl.save

    jl = grant.build_job_leads_content(aid)
    jl.content = "Good Morning $TRAINEEFIRSTNAME$,
                  Here are the recent job postings that match your profile.
                  $JOBLEADS$
                  $TRAINEE_SIGNIN_LINK$"
    jl.save

    create_applicant_sources
    create_unemployment_proofs
    create_special_services
    create_funding_sources
    create_employment_statuses

    c1 = create_college('Newark Campus', '765 Newman Springs Rd', 'Middletown', 'NJ',
                        '07738', 40.3279, -74.1334)

    create_user('Mariane', 'Hilpert', 'Middletown', 1, 1, 'hilpert@mail.com')
    create_user('Chris',   'Corkery', 'Middletown', 1, 2, 'corkery@mail.com')
    nav1 = create_user('Melinda', 'Peters', 'Camden', 1, 3, 'melinda1@mail.com')

    nav1.counties << nj_state.counties.where(name: 'Middlesex').first
    nav1.counties << nj_state.counties.where(name: 'Monmouth').first
    nav1.grants << grant

    nav3 = create_user('Cameron', 'Diaze', 'Camden', 1, 3, 'cameron@nomail.net')
    p1 = create_program('program 1', 'description of program11',
                          Sector.last.id, 400)

    k1 = create_klass(p1, 'CNC 101', '', 'June 27, 2012',  'Aug 17, 2018',
                        3, 272, c1.id)
    KlassNavigator.create(klass_id: k1.id, user_id: nav3.id)
  end

  def create_applicant_sources
    ['Neighbor2Neighbor', 'One Stop', 'NJBio',
     'Other, please specify.'].each { |ref| ApplicantSource.create!(source: ref) }
  end

  def create_unemployment_proofs
    UnemploymentProof.create(name: 'Letter from Employer (offer or termination)')
    UnemploymentProof.create(name: 'Letter from Unemployment Insurance Office(UI)')
  end

  def create_special_services
    ['None', 'Child Care', 'Financial or Behavioral Health Councelling'].each do |name|
      SpecialService.create(name: name)
    end
  end

  def create_funding_sources
    ['One Stop', 'HPOG', 'Self Pay'].each { |a| FundingSource.create!(name: a) }
  end

  def create_employment_statuses
    ['Employed Part Time', 'Unemployed(less than 6 months)'].each do |es|
      EmploymentStatus.create!(status: es, action: 'Accepted',
                               email_subject: 'rtw application',
                               email_body: '$FIRSTNAME$ $LASTNAME$, HELLO')
    end
    EmploymentStatus.create!(status: 'Employed Full Time', action: 'Declined',
                               email_subject: 'rtw application',
                               email_body: '$FIRSTNAME$ $LASTNAME$, NOPE')


  end

  def create_assessments
    ['Tabe', 'Accu Placer', 'Cyber Aces', 'WorkKeys', 'KeyTrain',
     'Bennett Mechanical Comprehension'].each { |a| Assessment.create!(name: a) }
  end

  def create_sectors
    ['aerospace, defense and security', 'airline industry', 'banking',
     'chemistry & pharma', 'consumer goods', 'health', 'insurance',
     'manufacturing', 'mining industry', 'public sector', 'telecom',
     'tourism', 'transport', 'utilities & energy'].each do |s|
      Sector.create!(name: s)
    end
  end

  def create_races

    ['American Indian/Alaska Native',
     'Asian',
     'Black or African American',
     'Do not wish to disclose',
     'Hawaiian Native or Other Pacific Islander',
     'Hispanic/Latino',
     'White'].each do |race|
      Race.create!(name: race)
    end
  end

  def create_education_levels
    n = 1

    ['Below High School',
     'GED',
     'High School Diploma',
     'Some college',
     'Post Secondary Credential or Certificate',
     "Associate’s Degree",
     "Bachelor’s Degree",
     'Graduate Degree or above'].each do |e|
      Education.create!(position: n, name: e)
      n += 1
    end
  end

  def create_states
    [ ['NJ', 'New Jersey'], ['NH', 'New Hampshire'], ['NM', 'New Mexico'],
      ['PA', 'Pennsylvania'], ['DE', 'Delaware'], ['TX', 'Texas']
      ].each { |code, name| State.create(code: code, name: name) }
    create_counties
  end

  def create_counties
    create_nj_counties
    create_nh_counties
    create_nm_counties
    create_pa_counties
    create_de_counties
    create_tx_counties
  end

  def create_de_counties
    ['Kent', 'New Castle', 'Sussex'].each { |c| de_state.counties.create(name: c) }
  end

  def create_nh_counties
    s = State.find_by(code: 'NH')
    %w(Belknap Carroll Cheshire Coos Grafton Hillsborough Merrimack Rockingham Strafford
       Sullivan).each { |c| s.counties.create(name: c) }
  end

  def create_nm_counties
    s = State.where(code: 'NM').first
    ['Bernalillo', 'Catron', 'Chaves', 'Cibola', 'Colfax', 'Curry', 'De Baca',
     'Dona Ana', 'Eddy', 'Grant', 'Guadalupe', 'Harding', 'Hidalgo', 'Lea', 'Lincoln',
     'Los Alamos', 'Luna', 'Mckinley', 'Mora', 'Otero', 'Quay', 'Rio Arriba',
     'Roosevelt', 'Sandoval', 'San Juan', 'San Miguel', 'Santa Fe', 'Sierra', 'Socorro',
     'Taos', 'Torrance', 'Union', 'Valencia'].each { |c| s.counties.create(name: c) }
  end

  def create_nj_counties
    ['Atlantic', 'Bergen', 'Burlington', 'Camden', 'Cape May', 'Cumberland', 'Essex',
     'Gloucester', 'Hudson', 'Hunterdon', 'Mercer', 'Middlesex', 'Monmouth', 'Morris',
     'Ocean', 'Passaic', 'Salem', 'Somerset', 'Sussex',
     'Union', 'Warren'].each { |c| nj_state.counties.create(name: c) }
  end

  def create_pa_counties
    %w(Adams Allegheny Armstrong Beaver Bedford Berks Blair Bradford Bucks Butler
       Cambria Cameron Carbon Centre Chester Clarion Clearfield Clinton Columbia
       Crawford Cumberland Dauphin Delaware Elk Erie Fayette Forest Franklin Fulton
       Greene Huntingdon Indiana Jefferson Juniata Lackawanna Lancaster Lawrence Lebanon
       Lehigh Luzerne Lycoming McKean Mercer Mifflin Monroe Montgomery Montour
       Northampton Northumberland Perry Philadelphia Pike Potter Schuylkill Snyder
       Somerset Sullivan Susquehanna Tioga Union Venango Warren Washington Wayne
       Westmoreland Wyoming York).each { |c| pa_state.counties.create(name: c) }
  end

  def create_tx_counties
    %w(Anderson Andrews Angelina Aransas Archer Armstrong Atascosa Austin Bailey Bandera
       Bastrop Baylor Bee Bell Bexar Blanco Borden Bosque Bowie Brazoria Brazos Brewster
       Williamson Wilson Winkler Wise Wood Yoakum Young Zapata
       Zavala).each { |c| tx_state.counties.create(name: c) }
  end

  def create_cities
    northampton, bucks, lycoming, monmouth, mercer = fetch_counties

    c_a = city_hash('Newtown', '18940', bucks.id, -74.75, 41.05)
    pa_state.cities.create(c_a)

    c_a = city_hash('Bethlehem', '18020', northampton.id, -75.36, 40.62)
    pa_state.cities.create(c_a)

    c_a = city_hash('Jersey Shore', '17740', lycoming.id, -77.26, 41.20)
    pa_state.cities.create(c_a)

    c_a = city_hash('Middletown', '', monmouth.id, -74.13, 40.33)
    nj_state.cities.create(c_a)

    c_a = city_hash('East Windsor', '', mercer.id, -74.54, 40.2677)
    nj_state.cities.create(c_a)

    create_cities_for_companies_search_spec
  end

  def create_cities_for_companies_search_spec
    hudson = nj_state.counties.where(name: 'Hudson').first
    c_a = city_hash('Union City', '07087', hudson.id, -74.03, 40.77)
    nj_state.cities.create(c_a)

    cape_may = nj_state.counties.where(name: 'Cape May').first
    c_a = city_hash('Cape May Court House', '08210', cape_may.id, -74.80, 39.12)
    nj_state.cities.create(c_a)

    ocean = nj_state.counties.where(name: 'Ocean').first
    c_a = city_hash('Brick', '08723', ocean.id, -74.1357407, 40.0508979)
    nj_state.cities.create(c_a)
  end

  def fetch_counties
    northampton  = pa_state.counties.where(name: 'Northampton').first
    bucks        = pa_state.counties.where(name: 'Bucks').first
    lycoming     = pa_state.counties.where(name: 'Lycoming').first
    monmouth     = nj_state.counties.where(name: 'Monmouth').first
    mercer       = nj_state.counties.where(name: 'Mercer').first
    [northampton, bucks, lycoming, monmouth, mercer]
  end

  def create_account(*a)
    account = Account.create!(name: a[0], description: a[1], client_type: a[2],
                              status: a[3], subdomain: a[4], logo_file: a[5])
    Account.current_id = account.id
    puts "created account #{account.name} with subdomain: #{account.subdomain}"
    account
  end

  def create_grant(*a)
    attrs = { name: a[0], start_date: a[1], end_date: a[2],
              status: a[3], spots: a[4], amount: a[5] }

    a[6].each { |k, v| attrs[k]  = v } if a[6]
    grant = Grant.create!(attrs)
    Grant.current_id = grant.id
    puts "created grant #{grant.name}"
    grant
  end

  def create_user(*a)
    pwd = 'password'
    attrs = { first: a[0], last: a[1], location: a[2], status: a[3], role: a[4],
              email: a[5], password: pwd, password_confirmation: pwd }
    User.create!(attrs)
  end

  def create_college(*a)
    address = { line1: a[1], city: a[2], state: a[3], zip: a[4],
                latitude: a[5], longitude: a[6] }
    College.create!(name: a[0], address_attributes: address)
  end

  def create_program(*a)
    Program.create!(name: a[0], description: a[1], sector_id: a[2], hours: a[3])
  end

  def create_klass(*a)
    p = a[0] # program
    p.klasses.create!(name: a[1], description: a[2], start_date: a[3], end_date: a[4],
                      credits: a[5], training_hours: a[6], college_id: a[7])
  end

  def create_trainee(*a) # first, last, email, address_attrs, klass
    attrs = { first: a[0], last: a[1], email: a[2] }
    attrs[:home_address_attributes] = address_hash(a[3]) if a[3]
    t = Trainee.create(attrs)
    a[4].trainees << t if a[4]
  end

  def address_hash(a)
    { line1: a[0], city: a[1], state: a[2], zip: a[3], latitude: a[4], longitude: a[5] }
  end

  def city_hash(*a)
    { name: a[0], zip: a[1], county_id: a[2], longitude: a[3], latitude: a[4] }
  end

  def create_employer(*a)
    Employer.create!(name: a[0],
      employer_source_id: EmployerSource.first.id,
      address_attributes: address_hash(a[1]))
  end

  def de_state
    State.where(code: 'DE').first
  end

  def nj_state
    State.where(code: 'NJ').first
  end

  def pa_state
    State.where(code: 'PA').first
  end

  def tx_state
    State.where(code: 'TX').first
  end

  def manufacturing
    Sector.find_by_name('manufacturing')
  end

  def transport
    Sector.find_by_name('transport')
  end
end
