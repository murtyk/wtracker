# frozen_string_literal: true

# data from demo account
class DemoData
  def generate(account_id)
    @account_id = account_id
    @nj = State.where(code: 'NJ').first
    @camden = @nj.counties.where(name: 'Camden').first
    @bergen = @nj.counties.where(name: 'Bergen').first
    @middlesex = @nj.counties.where(name: 'Middlesex').first
    Account.current_id = account_id
    account = Account.find(account_id)

    account.states << @nj

    generate_grant
    generate_users
    generate_employers
    generate_contacts
    generate_colleges
    generate_program
    generate_klasses
    generate_visits_events
    generate_klass_titles
    generate_students
  end

  def generate_grant
    grant_params = { account_id: @account_id.to_s, name: 'MFG Workforce',
                     start_date: (Date.today - 2.years).to_s,
                     end_date: (Date.today + 2.years).to_s,
                     status: '2', spots: '', amount: '',
                     auto_job_leads: '0',
                     profile_request_subject_attributes: { content: '' },
                     profile_request_content_attributes: { content: '' },
                     job_leads_subject_attributes: { content: '' },
                     job_leads_content_attributes: { content: '' },
                     optout_message_one_attributes: { content: '' },
                     optout_message_two_attributes: { content: '' },
                     optout_message_three_attributes: { content: '' } }

    @grant = GrantFactory.build_grant(grant_params)
    @grant.save
    Grant.current_id = @grant.id
  end

  def generate_users
    # 1 admin
    # 2 navigators
    # 2 instructors

    # first check if aandrola@gmail.com already exisits
    admin_email = generate_admin_email
    user_params = { first: 'Angela', last: 'Androla', email: admin_email,
                    password: 'password', location: 'Windsor,NJ', role: '2',
                    status: '1', comments: '' }

    User.create(user_params)
  end

  def generate_employers
    sector = Sector.where('name ilike ?', 'Manufacturing%').first
    [CAMDEN_COMPANIES, BERGEN_COMPANIES].each do |companies|
      companies.each do |emp|
        name = emp[0]
        phone_no = emp[1]
        website = emp[2]
        address = { line1: emp[3], city: emp[4], county: emp[5], county_id: emp[6],
                    state: emp[7], zip: emp[8], latitude: emp[9], longitude: emp[10] }
        emp = Employer.create(name: name,
                              phone_no: phone_no,
                              website: website,
                              employer_source_id: EmployerSource.first.id,
                              address_attributes: address)
        emp.sectors << sector
      end
    end
  end

  def generate_contacts
    n = 0
    [CAMDEN, BERGEN].each do |county|
      fetch_companies(county, 10).each do |emp|
        contact = CONTACTS[n]
        phone_parts = contact[3].split('x')
        land_no = phone_parts[0]
        ext = phone_parts[1]
        emp.contacts.create(first: contact[0], last: contact[1], email: contact[2],
                            land_no: land_no, ext: ext)
        n += 1
      end
    end
  end

  def generate_colleges
    address = { line1: '200 N Broadway', city: 'Camden', state: 'NJ', zip: '08102',
                county_id: @camden.id, county: 'Camden',
                longitude: -75.1179, latitude: 39.946686 }
    @camden_college = College.create(name: 'Camden County College',
                                     address_attributes: address)

    address = { line1: '400 Paramus Road', city: 'Paramus', state: 'NJ', zip: '07652',
                county_id: @bergen.id, county: 'Bergen',
                longitude: -74.08855, latitude: 40.9512659 }
    @bergen_college = College.create(name: 'Bergen Community College',
                                     address_attributes: address)

    address = { line1: '2600 Woodbridge Ave', city: 'Edison', state: 'NJ', zip: '08818',
                county_id: @middlesex.id, county: 'Middlesex', longitude: -74.365144,
                latitude: 40.5041977 }

    @middlesex_college = College.create(name: 'Middlesex County College',
                                        address_attributes: address)
  end

  def generate_program
    @program = Program.create(name: 'Advanced Manufacturing',
                              description: 'Develop workforce with mfg skills',
                              sector_id: 8)
  end

  def generate_klasses
    @camden_klass = Klass.create(program_id: @program.id, college_id: @camden_college.id,
                                 name: 'CNC 101',
                                 start_date: Date.parse('8th Sep 2014'),
                                 end_date: Date.parse('7th Nov 2014'))
    [1, 3, 5, 6].each { |d| @camden_klass.klass_schedules.create(dayoftheweek: d) }
    @camden_klass.klass_schedules.create(dayoftheweek: 2, scheduled: true,
                                         start_time_hr: 9, end_time_hr: 2)
    @camden_klass.klass_schedules.create(dayoftheweek: 4, scheduled: true,
                                         start_time_hr: 10, end_time_hr: 3)

    @bergen_klass = Klass.create(program_id: @program.id, college_id: @bergen_college.id,
                                 name: 'Welding 101',
                                 start_date: Date.parse('15th Sep 2014'),
                                 end_date: Date.parse('13th Nov 2014'))
    [1, 2, 5, 6].each { |d| @bergen_klass.klass_schedules.create(dayoftheweek: d) }
    @bergen_klass.klass_schedules.create(dayoftheweek: 3, scheduled: true,
                                         start_time_hr: 9, end_time_hr: 2)
    @bergen_klass.klass_schedules.create(dayoftheweek: 4, scheduled: true,
                                         start_time_hr: 10, end_time_hr: 3)
  end

  def generate_visits_events
    # for each class, 1 information session and 2 class visits
    # 1 of each already created, we need to create one more class visit
    # let us set all events at 10am for 1 hour

    [@camden_klass, @bergen_klass].each do |klass|
      event = klass.klass_events.where(name: 'Information Session').first
      event.update(start_time_hr: 10, end_time_hr: 11, end_ampm: 'am')
      # event.start_time_hr = 10
      # event.end_time_hr = 11
      # event.end_ampm = 'am'
      # event.save

      company_ids = fetch_companies(klass.county, 10).pluck(:id)
      company_ids[0..3].each do |c_id|
        event.klass_interactions.create(employer_id: c_id, status: 1)
      end
      company_ids[4..7].each do |c_id|
        event.klass_interactions.create(employer_id: c_id, status: 2)
      end

      event = klass.klass_events.where(name: 'Class Visit').first
      event.update(start_time_hr: 10, end_time_hr: 11, end_ampm: 'am')
      # event.start_time_hr = 10
      # event.end_time_hr = 11
      # event.end_ampm = 'am'
      # event.save
      event.klass_interactions.create(employer_id: company_ids[8], status: 2)

      event = klass.klass_events.create(name: 'Class Visit',
                                        event_date: Date.today + 40.days,
                                        start_time_hr: 10, end_time_hr: 11,
                                        end_ampm: 'am')
      event.klass_interactions.create(employer_id: company_ids[9], status: 1)
    end
  end

  def generate_klass_titles
    ['Machine Operator', 'CNC', 'weld'].each do |title|
      @camden_klass.klass_titles.create(title: title)
      @bergen_klass.klass_titles.create(title: title)
    end
  end

  def fetch_companies(county, n)
    companies = CAMDEN_COMPANIES if county == CAMDEN
    companies = BERGEN_COMPANIES unless county == CAMDEN
    company_names = companies.map { |c| c[0] }
    Employer.where(name: company_names).limit(n)
  end

  TITLES = ['Machinist', 'Welder', 'CNC Operator',
            'Mechanic', 'CNC Machinist', 'Fabricator'].freeze
  SALARIES = ['$13/hr', '$14/hr', '$15/hr', '$13.50/hr', '$18/hr', '$25/hr'].freeze

  def generate_students
    generate_camden_students
    generate_bergen_students
  end

  def generate_camden_students
    10.times do |n|
      @camden_klass.trainees << Trainee.create(student_attribues(CAMDEN, n))
    end

    # camden: 1 dropped, 9 completed, 6 placed out of 9 completed
    @camden_klass.klass_trainees.each { |kt| kt.update(status: 2) }
    @camden_klass.klass_trainees[2].update(status: 3)
    klass_trainees = @camden_klass.klass_trainees[4..9]
    trainees = klass_trainees.map(&:trainee)
    employer_ids = fetch_companies(CAMDEN, 6).pluck(:id)
    (0..5).each do |n|
      attributes = { employer_id: employer_ids[n],
                     start_date: Date.today + (n + 1).days,
                     hire_title: TITLES[n], hire_salary: SALARIES[n] }
      trainees[n].trainee_interactions.create(attributes)
    end
  end

  def generate_bergen_students
    10.times do |n|
      @bergen_klass.trainees << Trainee.create(student_attribues(BERGEN, n))
    end

    # bergen: 10 completed, 1 continuing, 3 placed
    @bergen_klass.klass_trainees.each { |kt| kt.update(status: 2) }
    @bergen_klass.klass_trainees[2].update(status: 5)
    klass_trainees = @bergen_klass.klass_trainees[4..6]
    trainees = klass_trainees.map(&:trainee)
    employer_ids = fetch_companies(BERGEN, 3).pluck(:id)
    (0..2).each do |n|
      attributes = { employer_id: employer_ids[n],
                     start_date: Date.today + (n + 1).weeks,
                     hire_title: TITLES[n], hire_salary: SALARIES[n] }
      trainees[n].trainee_interactions.create(attributes)
    end
  end

  def student_attribues(county, n)
    if county == CAMDEN
      student = CAMDEN_STUDENTS[n]
      addr = CAMDEN_ADDRESSES[n]
      county_id = @camden.id
    else
      student = BERGEN_STUDENTS[n]
      addr = BERGEN_ADDRESSES[n]
      county_id = @bergen.id
    end
    {
      first: student[0], last: student[1], email: student[2],
      home_address_attributes: { line1: addr[0], city: addr[1], zip: addr[2],
                                 longitude: addr[3], latitude: addr[4],
                                 county: county, county_id: county_id, state: 'NJ' }
    }
  end

  def generate_admin_email
    exists = User.unscoped.where(email: 'aandrola@gmail.com').any?
    return 'aandrola@gmail.com' unless exists

    n = 1
    n += 1 while User.unscoped.where(email: "aandrola#{n}@gmail.com").any?
    "aandrola#{n}@gmail.com"
  end

  CAMDEN_COMPANIES = [
    ['Vermes Machine Co', '8566429300', 'www.vermesmachine.com', '351 Crider Ave',
     'Moorestown', 'Burlington', 1772, 'NJ', '08057', 39.9689, -74.9771],
    ['Virtua', '8563223000',
     'http://www.virtua.org/locations/hospitals-and-locations/virtua-berlin.aspx',
     '100 Townsend Avenue', 'Berlin', 'Camden', 1773, 'NJ', '08009',
     39.782578, -74.920857],
    ['John Crane Inc', '8562413507', 'http://www.johncrane.com/',
     '301 Berkley Dr', 'Swedesboro', 'Gloucester', 1777, 'NJ', '08085',
     39.7648, -75.3352],
    ['US Vision', '8562289446', 'http://www.usvision.com/',
     '10 Harmon Dr', 'Blackwood', 'Camden', 1773, 'NJ', '08012', 39.831172, -75.074026],
    ['Connector Products', '8568299190', 'connectorproducts.com',
     'Surrey Ln', 'Delran', 'Burlington', 1772, 'NJ', '08075', 40.011923, -74.9699],
    ['3D Medical Manufacturing', '8564869600', 'www.3dmedicalmfg.com', '7145 Colonial Ln',
     'Pennsauken Township', 'Camden', 1773, 'NJ', '08109', 39.931789, -75.074907],
    ['The Inventors Shop', '8563038787', 'www.inventorsshop.com', '800 Industrial Hwy',
     'Cinnaminson', 'Burlington', 1772, 'NJ', '08077', 40.014215, -74.997685],
    ['Gillman & Pinto PC', '8569396600', 'www.gillmanlevin.com', '401 Highway 73',
     'Evesham Township', 'Burlington', 1772, 'NJ', '08053', 39.899955, -74.936714],
    ['Aluminum Shapes LLC', '8566625500', 'http://www.shapesllc.com/',
     '9000 River Road', 'Delair', 'Camden', 1773, 'NJ', '08110', 39.986982, -75.046002],
    ['Randstad', '8562418881', 'http://us.randstad.com/', '553 Beckett Road',
     'Swedesboro', 'Gloucester', 1777, 'NJ', '08085', 39.76, -75.35],
    ['Advanced Drainage Systems Inc', '8564674779', 'www.ads-pipe.com',
     '300 Progress Ct', 'Swedesboro', 'Gloucester', 1777, 'NJ', '08085',
     39.773318, -75.38475],
    ['Intelligent Machine Control', '8567685370', 'www.imcbox.com',
     '423 Commerce Lane', 'Berlin Township', 'Camden', 1773, 'NJ', '08091',
     39.810394, -74.926582],
    ['Lockheed Martin', '8567223336', 'www.lockheedmartin.com',
     '199 Borton Landing Rd', 'Moorestown', 'Burlington', 1772, 'NJ', '08057',
     39.975825, -74.91648],
    ['POWER Engineers', '6095702721', 'www.powereng.com', 'American Metro Blvd',
     'Trenton', 'Mercer', 1780, 'NJ', '08619', 40.256167, -74.707355],
    ['Denton Vacuum Inc', '8564399100', 'www.dentonvacuum.com',
     '1259 N Church St', 'Moorestown', 'Burlington', 1772, 'NJ', '08057',
     39.9785, -74.9841],
    ['Radwell International Inc', '8567788924', 'www.plccenter.com',
     '111 Mt Holly Bypass', 'Lumberton', 'Burlington', 1772, 'NJ', '08048',
     39.973868, -74.805024],
    ['Ingersoll Rand', '8003477047', 'ingersollrand.com',
     '1467 Route 31', 'Clinton Township', 'Hunterdon', 1779, 'NJ', '08801',
     40.632574, -74.885003],
    ['Diedre Moire Corporation', '6095849000', 'www.diedremoire.com',
     '510 Horizon Dr', 'Trenton', 'Mercer', 1780, 'NJ', '08691',
     40.199136, -74.642453],
    ['Synerfac Inc', '3023249400', 'www.synerfac.com',
     '2 Reads Way', 'New Castle', 'New Castle', 315, 'DE', '19720', 39.687631, -75.609367]
  ].freeze
  BERGEN_COMPANIES = [
    ['Arlington Machine & Tool Co', '9732761377', 'http://www.arlingtonmachine.com/',
     '90 New Dutch Ln', 'Fairfield', 'Essex', 1776, 'NJ', '07004', 40.881664, -74.278388],
    ['Triangle Manufacturing Co., Inc.', '2018251212', 'http://www.trianglemfg.com/',
     '116 Pleasant Avenue', 'Upper Saddle Rvr', 'Bergen', 1771, 'NJ', '07458',
     41.05097, -74.120353],
    ['Auto-Chlor System', '2014382772', 'www.autochlor.net', '685 Gotham Pkwy',
     'Carlstadt', 'Bergen', 1771, 'NJ', '07072', 40.831111, -74.065888],
    ['Englewood Hospital & Medical Center', '2018943000', 'www.englewoodhospital.com',
     '350 Engle St', 'Englewood', 'Bergen', 1771, 'NJ', '07631', 40.903997, -73.968469],
    ['Heisler Industries', '9732276300', 'www.heislerind.com', '224 County Road 613',
     'Fairfield', 'Essex', 1776, 'NJ', '07004', 40.876677, -74.270056],
    ['Labor Ready', '2014538738', 'www.laborready.com', '7611 Bergenline Ave',
     'North Bergen', 'Hudson', 1778, 'NJ', '07047', 40.8004, -74.007869],
    ['National Steel Rule', '9088623367', 'steelrule.com', '750 Commerce Rd', 'Linden',
     'Union', 1789, 'NJ', '07036', 40.633747, -74.238589],
    ['Sharp Electronics Corporation', '2015298200', 'www.sharpusa.com', '1 Sharp Plaza',
     'Mahwah', 'Bergen', 1771, 'NJ', '07495', 41.110853, -74.161718],
    ['Sodexo', '2019341211', 'www.sodexousa.com', '505 Ramapo Valley Rd', 'Mahwah',
     'Bergen', 1771, 'NJ', '07430', 41.083947, -74.176609],
    ['UTC Aerospace Systems', '9737851062', 'utcaerospacesystems.com', '20 Commerce Way',
     'Totowa', 'Passaic', 1785, 'NJ', '07512', 40.9099, -74.234942],
    ['Unity Steel Rule Die Co', '2015696400', '', '210 S Van Brunt St', 'Englewood',
     'Bergen', 1771, 'NJ', '07631', 40.88865, -73.981297],
    ['Van Ness Plastic Molding Co', '9737789500', 'www.vannessplastic.com',
     '400 Brighton Rd', 'Clifton', 'Passaic', 1785, 'NJ', '07012', 40.856599, -74.156191],
    ['Precision Technology Inc', '2017671600', 'www.ptiplastics.com', '50 Maple St',
     'Norwood', 'Bergen', 1771, 'NJ', '07648', 40.993172, -73.949829],
    ['Harmon Stores Inc.', '9732566010', 'www.harmondiscount.com', '465 Totowa Rd',
     'Totowa', 'Passaic', 1785, 'NJ', '07512', 40.903891, -74.214705],
    ['Valcor Engineering Corporation', '9734678400', 'www.valcor.com', '2 Lawrence Rd',
     'Springfield Township', 'Union', 1789, 'NJ', '07081', 40.683617, -74.323003],
    ['Ferguson Enterprises Inc', '2018638587', 'www.ferguson.com', '369 Anderson Ave',
     'Fairview', 'Bergen', 1771, 'NJ', '07022', 40.818919, -73.993124],
    ['Integration International, Inc.', '9737962300', 'www.i3intl.com',
     '160 Littleton Rd', 'Parsippany', 'Morris', 1783, 'NJ', '07054',
     40.866981, -74.419783],
    ['Pentad', '2014401101', '', '425 Main St', 'Ridgefield Park', 'Bergen', 1771, 'NJ',
     '07660', 40.865572, -74.022849],
    ['Amerlux LLC', '9738825010', 'www.amerlux.com', '23 Daniel Rd', 'Fairfield',
     'Essex', 1776, 'NJ', '07004', 40.883043, -74.278757],
    ['Flowserve Corporation', '9732274565', 'www.flowserve.com', '142 Clinton Rd',
     'Fairfield', 'Essex', 1776, 'NJ', '07004-2914', 40.86732, -74.311902],
    ['4 Over Inc', '2014401656', 'www.4over.com', '4 Empire Blvd', 'Moonachie',
     'Bergen', 1771, 'NJ', '07074', 40.833484, -74.049404],
    ['Crestron Electronics Inc', '2017673400', 'www.crestron.com', '6 Volvo Dr',
     'Rockleigh', 'Bergen', 1771, 'NJ', '07647', 41.010516, -73.936852],
    ['M C Machinery Systems Inc', '9732441501', 'www.mcmachinery.com', '16 Chapin Road',
     'Montville', 'Morris', 1783, 'NJ', '07058', 40.857402, -74.339845]
  ].freeze

  CONTACTS = [
    ['Lulu', 'Wilkinson', 'lulu_wilkinson@lueilwitzchristiansen.net',
     '(227)413-2573 x19014'],
    ['Timothy', 'Stehr', 'stehr.timothy@bahringerbotsford.info', '(356)342-6568'],
    ['Adolph', 'Rowe', 'rowe.adolph@schambergerstiedemann.name', '136-453-7111 x94634'],
    ['Owen', 'Schaden', 'schaden_owen@kuphal.info', '437-783-2291 x991'],
    ['Sofia', 'Purdy', 'purdy.sofia@mckenzierice.com', '1-732-004-8141 x1404'],
    ['Michelle', 'Jast', 'jast_michelle@bednar.net', '2307775755'],
    ['Karson', 'Labadie', 'karson.labadie@kuhicswift.org', '572-881-7813'],
    ['Duncan', 'Huels', 'duncan_huels@cummings.name', '1732736695 x63035'],
    ['Maryjane', 'Brown', 'maryjane.brown@lind.net', '(454)650-8969'],
    ['Elliot', 'Bernhard', 'elliot.bernhard@bartoletti.name', '9113758896 x3719'],
    ['Ari', 'Mueller', 'mueller.ari@reynolds.name', '522-723-6212'],
    ['Mitchell', 'Schneider', 'mitchell.schneider@wyman.net', '930-554-0833 x317'],
    ['Clifford', 'Volkman', 'volkman.clifford@cummings.com', '4514077891 x4383'],
    ['Michel', 'Murazik', 'michel_murazik@romaguera.org', '6352148663'],
    ['Mollie', 'Oberbrunner', 'mollie_oberbrunner@armstrong.info', '3156432558 x9207'],
    ['Joe', 'McClure', 'joe_mcclure@skiles.net', '3843979922 x22500'],
    ['Fae', 'Hirthe', 'fae.hirthe@robertsrowe.com', '1-587-189-1275'],
    ['Josefa', 'Gorczany', 'josefa.gorczany@mcdermott.name', '1-639-211-6275'],
    ['Milford', 'Kemmer', 'kemmer_milford@ward.net', '6701116487 x85745'],
    ['Daisha', 'Bergnaum', 'daisha.bergnaum@moen.info', '6386750985']
  ].freeze

  CAMDEN = 'Camden'
  BERGEN = 'Bergen'
  CAMDEN_STUDENTS = [['Freida', 'Walsh', 'walsh_freida@spinka.biz'],
                     ['Cora', 'Doyle', 'doyle.cora@mcclure.name'],
                     ['Caesar', 'Reichert', 'caesar_reichert@grahambuckridge.net'],
                     ['Flo', 'Wiegand', 'flo_wiegand@rodriguezdickens.net'],
                     ['Mackenzie', 'Jacobs', 'jacobs.mackenzie@lubowitz.net'],
                     ['Deondre', 'Turcotte', 'deondre_turcotte@schmeler.org'],
                     ['Heaven', 'Bergstrom', 'heaven.bergstrom@heller.com'],
                     ['Torrance', 'Denesik', 'torrance.denesik@dietrich.biz'],
                     ['Esteban', 'Konopelski', 'konopelski_esteban@crona.info'],
                     ['Tad', 'Jakubowski', 'tad_jakubowski@ferryankunding.org']].freeze

  CAMDEN_ADDRESSES = [
    ['103 Borlow Ave', 'Cherry Hill', '08002', -75.0337349, 39.947992],
    ['1620 Bryant Road', 'Cherry Hill', '08003', -75.003447, 39.872679],
    ['9 Ablett Village', 'Camden', '08105', -75.0903154, 39.9546859],
    ['212 S. 35th St', 'Camden', '08105', -75.072738, 39.945766],
    ['1134 South Merrimac Street', 'Camden', '08104', -75.106094, 39.902619],
    ['319 Hillcest Ave', 'Blackwood', '08012', -75.054754, 39.794185],
    ['51 Harding Ave', 'Runnemede', '08078', -75.068009, 39.850352],
    ['16 Fox Hollow Lane', 'Camden', '08081', -74.9833869, 39.728801],
    ['7515 Fallon Drive', 'Pennsauken', '08109', -75.039769, 39.970259],
    ['315 Market Street', 'Gloucester City', '08030', -75.12503, 39.895825],
    ['713 South Cherry Street', 'Camden', '08103', -75.1154926, 39.9347912],
    ['377 Rand Street', 'Camden', '08105', -75.089149, 39.940888],
    ['6016 Jefferson Avenue', 'Pennsauken', '08110', -75.0574029, 39.96075],
    ['1125 Pederson Blvd', 'Atco', '08004', -74.828726, 39.753122],
    ['205 Lincoln Ave', 'Magnolia', '08049', -75.035846, 39.857423],
    ['41 Sherri Way', 'Pinehill', '08021', -75.009784, 39.796959],
    ['3711 Federal St', 'Pennsauken', '08110', -75.071393, 39.948257],
    ['117 Cleveland Ave', 'Mt. Ephraim', '08059', -75.097287, 39.876828],
    ['101 Frankline Ave #2', 'Berlin', '08009', -74.967099, 39.773944],
    ['1907 47th St', 'Pennsauken', '08110', -75.068571, 39.958129],
    ['5 Cliff Court', 'Erial', '08081', -75.010648, 39.755459],
    ['4006 Tracy Ct', 'Voorhees', '08043', -75.000193, 39.846236],
    ['8947 Harvey Avenue', 'Pennsauken', 'NH', '08110', -75.023947, 39.970888],
    ['622 Abertson Rd', 'Winslow', '08095', -74.865777, 39.653692],
    ['622 Abertson Rd', 'Winslow', '08095', -74.865777, 39.653692]
  ].freeze

  BERGEN_STUDENTS = [['Alana', 'Cummings', 'cummings_alana@tromp.com'],
                     ['Norris', 'Bahringer', 'bahringer_norris@reilly.name'],
                     ['Candice', 'Littel', 'littel_candice@collier.biz'],
                     ['Maxwell', 'Harber', 'harber_maxwell@framikoepp.name'],
                     ['Margie', 'Hermann', 'hermann.margie@wisoky.com'],
                     ['Efren', 'Koepp', 'efren_koepp@bartell.org'],
                     ['Alexandre', 'Cruickshank', 'cruickshank.alexandre@howe.info'],
                     ['Fabiola', 'Kreiger', 'fabiola.kreiger@becker.org'],
                     ['Vernon', 'Schimmel', 'schimmel.vernon@glover.biz'],
                     ['Marianna', 'Lind', 'lind_marianna@jacobi.name']].freeze

  BERGEN_ADDRESSES = [
    ['136 Evans Place', 'Saddle Brook', '07663', -74.1012978, 40.9177056],
    ['280 Genesee Avenue', 'Englewood', '07631', -73.990321, 40.892714],
    ['360 Innes Road', 'Woodridge', '07075', -74.085802, 40.852596],
    ['309 Prospect Ave, Apt. 3D', 'Hackensack', '07601', -74.053343, 40.8931381],
    ['514 6th St.', 'Lyndhurst', '07071', -74.124157, 40.804739],
    ['255 Warren St, Apt 1E', 'Englewood', '07631', -73.9896212, 40.890707],
    ['311 Chase Avenue', 'Lyndhurst', '07071', -74.12247, 40.810145],
    ['304 Ramopo Brae Lane', 'Mahwah', '07430', -74.174568, 41.0966566],
    ['36 Marshall Avenue', 'Little Ferry', '07643', -74.0392887, 40.8478385],
    ['160  Bergen Avenue, Apt 13', 'Ridgefield Park', '07660', -74.023133, 40.859727],
    ['103 New York Ave', 'Bergenfield', '07621', -73.98914, 40.935732],
    ['323 Banterbury Ln', 'Wyckoff', '07481', -74.158893, 40.996899],
    ['57 Clinton Park Drive', 'Bergenfield', '07621', -73.986491, 40.926434],
    ['229 3rd Street', 'Ridgefield Park', '07660', -74.028513, 40.866326],
    ['54 Craig Road', 'Montvale', '07645', -74.063338, 41.05671],
    ['139 Magnolia Avenue', 'Tenafly', '07670', -73.959427, 40.930963],
    ['65 Rutgers Place', 'River Edge', '07661', -74.0372426, 40.9133915],
    ['21A Edgewater Place', 'Edgewater', '07020', -73.976294, 40.824168],
    ['229 3rd Street', 'Ridgefield Park', '07660', -74.028513, 40.866326],
    ['435 Hudson Street', 'Hackensack', '07601', -74.0387149, 40.8646871],
    ['1 Highwood Road', 'Ramsey', '07446', -74.151387, 41.043299],
    ['289 Washington Street', 'Saddle Brook', '07663', -74.086342, 40.903981],
    ['334 Pond Court', 'Township of Washington', '07676', -74.066687, 40.9775644],
    ['334 Palisade ave', 'Cliffside park', '07010', -73.9905653, 40.815962]
  ].freeze

  MIDDLESEX_STUDENTS = [['Winnifred', 'Jast', 'winnifred_jast@sawayn.org'],
                        ['Ella', 'Brakus', 'brakus_ella@reillybalistreri.name'],
                        ['Kian', 'Lesch', 'kian_lesch@marks.com'],
                        ['Wilhelmine', 'Lynch', 'lynch_wilhelmine@muller.net'],
                        ['Andrew', 'Conner', 'conner.andrew.o@lynch.com'],
                        ['Ramona', 'Windler', 'windler_ramona@framibogan.info'],
                        ['Pietro', 'Jerde', 'pietro.jerde@blick.com'],
                        ['Sheldon', 'Dare', 'dare_sheldon@bahringer.info'],
                        ['Darwin', 'Zulauf', 'darwin.zulauf@barrows.name'],
                        ['Kaylie', 'Hodkiewicz', 'hodkiewicz.kaylie@cain.biz']].freeze
end
