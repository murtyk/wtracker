# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each { |seed| load seed }

Admin.create(email: 'wtracker@wtracker.com', password: 'password', password_confirmation: 'password')
Account.create(name: 'operotest', description: 'Application Account Reserved', client_type: 1, status: 1, subdomain: 'operotest', logo_file: "")
account = Account.create(name: 'operostaging', description: 'Application Account Reserved', client_type: 1, status: 1, subdomain: 'operostaging', logo_file: "")
grant1 = account.grants.create!(name: 'Grant 1', start_date: 'Jan 1, 2012', end_date: 'Dec 31, 2015', status: 2, spots: 100, amount: 5000000)

#first reference data

sector1 = Sector.find_by_name("manufacturing")
sector2 = Sector.find_by_name("transport")


# 		# we will create 3 different accounts
# 		# account 1 - opero account
# 		# account 2 - alamo

account = Account.create(name: 'opero', description: 'Application Account Reserved', client_type: 1, status: 1, subdomain: 'opero', logo_file: "alamo.png")
["Tabe", "Accu Placer", "Cyber Aces", "WorkKeys", "KeyTrain", "Bennett Mechanical Comprehension"].each{|a| account.assessments.create!(name: a)}

Account.current_id = account.id
director = account.users.create!(first: 'James', last: 'Cameron', location: 'Princeton', status: 1, role: 1, email: 'james@mail.com', password: 'password', password_confirmation: 'password')
client_admin = account.users.create!(first: 'Bob', last: 'Dylan', location: 'Trenton', status: 1, role: 2, email: 'bob@mail.com', password: 'password', password_confirmation: 'password')
grant1 = account.grants.create!(name: 'Grant 1', start_date: 'Jan 1, 2012', end_date: 'Dec 31, 2015', status: 2, spots: 100, amount: 5000000)
grant2 = account.grants.create!(name: 'Grant 2', start_date: 'June 1, 2014', end_date: 'Dec 31, 2018', status: 1, spots: 50, amount: 2000000)


nj_state = State.where(code: 'NJ').first
county_camden = County.create(name: 'Camden', state_id: nj_state.id)
county_middlesex = County.create(name: 'Middlesex', state_id: nj_state.id)
county_passaic = County.create(name: 'Passaic', state_id: nj_state.id)
county_bergen = County.create(name: 'Bergen', state_id: nj_state.id)

college1 = account.colleges.create!(name: 'Camden county college')
college1.address = Address.create(line1: '200 N Broadway', city: 'Camden', state: 'NJ', zip:'08102', county_id: county_camden.id)
college2 = account.colleges.create!(name: 'Middlesex county college')
college2.address = Address.create(line1: '2600 Woodbridge Ave', city: 'Edison', state: 'NJ', zip:'08818', county_id: county_middlesex.id)
college3 = account.colleges.create!(name: 'Passaic Technical Institue')
college3.address = Address.create(line1: '45 Reinhardt Rd', city: 'Wayne', state: 'NJ', zip:'07470', county_id: county_passaic.id)
college4 = account.colleges.create!(name: 'NJITNJ')
college4.address = Address.create(line1: '323 Martin Luther KIng Jr. Blvd', city: 'Newark', state: 'NJ', zip:'07102', county_id: county_passaic.id)
college5 = account.colleges.create!(name: 'Bergen Community College')
college5.address = Address.create(line1: '400 Paramus Road', city: 'Paramus', state: 'NJ', zip:'07652', county_id: county_bergen.id)

nav1 = account.users.create!(first: 'Linda', last: 'Peters', location: 'Camden', status: 1, role: 3, email: 'linda@mail.com', land_no:'2125553333', ext: '654', mobile_no: '6099832424',password: 'password', password_confirmation: 'password')
nav2 = account.users.create!(first: 'Susan', last: 'Prisco', location: 'Mercer', status: 1, role: 3, email: 'susan@mail.com', land_no:'9125553333', ext: '504', password: 'password', password_confirmation: 'password')
nav3 = account.users.create!(first: 'Lisa', last: 'Logan', location: 'Burlington', status: 1, role: 3, email: 'lisa@mail.com', land_no:'6351893287', password: 'password', password_confirmation: 'password')
nav4 = account.users.create!(first: 'Nancy', last: 'Grace', location: 'Mercer', status: 1, role: 3, email: 'nancy@mail.com', password: 'password', password_confirmation: 'password')
inst1 = account.users.create!(first: 'Sean', last: 'Ben', location: 'Mercer', status: 1, role: 4, email: 'sean@mail.com', password: 'password', password_confirmation: 'password')
inst2 = account.users.create!(first: 'Hugh', last: 'Grant', location: 'Mercer', status: 1, role: 4, email: 'hugh@mail.com', password: 'password', password_confirmation: 'password')


# # ----------------------------------------Account 2 ---------------------------------------------------------

# #-----------------------------------------College------------------------------------------

account = Account.create(name: 'Alamo Colleges', description: 'Consortium of Colleges of TX', client_type: 2, status: 1, subdomain: 'alamo', logo_file: "alamo.png")
["Tabe", "Accu Placer", "Cyber Aces", "WorkKeys", "KeyTrain", "Bennett Mechanical Comprehension"].each{|a| account.assessments.create!(name: a)}


Account.current_id = account.id
college1 = account.colleges.create!(name: 'Northeast Lakeview College')
college2 = account.colleges.create!(name: 'Northwest Vista College')
college3 = account.colleges.create!(name: 'Palo Alto College')
college4 = account.colleges.create!(name: 'San Antonio College')


director = account.users.create!(first: 'Abby', last: 'Gonzalez', location: 'San Antonio', status: 1, role: 1, email: 'abby@mail.com', password: 'password', password_confirmation: 'password')
client_admin = account.users.create!(first: 'Brenda', last: 'Androla', location: 'San Antonio', status: 1, role: 2, email: 'brenda@mail.com', password: 'password', password_confirmation: 'password')
grant1 = account.grants.create!(name: 'Grant 1', start_date: 'Jan 1, 2012', end_date: 'Dec 31, 2015', status: 2, spots: 0, amount: 0)
nav1 = account.users.create!(first: 'Gloria', last: 'Perez', location: 'San Antonio', status: 1, role: 3, email: 'gloria@mail.com', password: 'password', password_confirmation: 'password')
nav2 = account.users.create!(first: 'Nina', last: 'Mc Garth', location: 'San Antonio', status: 1, role: 3, email: 'nina@mail.com', password: 'password', password_confirmation: 'password')
inst1 = account.users.create!(first: 'Palmira', last: 'Rendon', location: 'San Antonio', status: 1, role: 4, email: 'palmira@mail.com', password: 'password', password_confirmation: 'password')
inst2 = account.users.create!(first: 'John', last: 'Braxton', location: 'San Antonio', status: 1, role: 4, email: 'john@mail.com', password: 'password', password_confirmation: 'password')

p1 = grant1.programs.create(name: 'program1', description: 'description of program11', sector_id: sector1.id, hours: 400)
p2 = grant1.programs.create(name: 'program2', description: 'description of program12', sector_id: sector2.id, hours: 300)

Grant.current_id = grant1.id
c111 = p1.klasses.create!(credits: 4, description: "Class 1 for Program 1", end_date: "Dec 31, 2014", name: "Class1", start_date: "Jan 1, 2014", training_hours: 100, college_id: college1.id)
c112 = p1.klasses.create!(credits: 2, description: "Class 2 for Program 1", end_date: "Dec 31, 2014", name: "Class2", start_date: "June 1, 2014", training_hours: 50, college_id: college2.id)
c121 = p2.klasses.create!(credits: 2, description: "Class 1 for Program 2", end_date: "Dec 31, 2014", name: "Class3", start_date: "June 1, 2014", training_hours: 50, college_id: college1.id)
c211 = p2.klasses.create!(credits: 4, description: "Class 1 for Program 2", end_date: "Dec 31, 2014", name: "Class4", start_date: "Jan 1, 2014", training_hours: 100, college_id: college2.id)

state_tx = State.where(code: 'TX').first
county = County.create!(name: 'Bexar', state_id: state_tx.id)

emp1 = account.employers.create!(name: 'BE&SCO Manufacturing', source: 'google')
emp1.address = Address.create!(line1: '1623 North San Marcos', city: 'San Antonio', state: 'TX', zip:'78201', county_id: county.id)
emp2 = account.employers.create!(name: 'Goodyear', source: 'google')
emp2.address = Address.create!(line1: '5722 Babcock Rd', city: 'San Antonio', state: 'TX', zip:'78240', county_id: county.id)
