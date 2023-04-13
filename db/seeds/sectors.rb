# frozen_string_literal: true

['aerospace, defense and security', 'airline industry', 'banking', 'chemistry & pharma',
 'consumer goods', 'health', 'insurance', 'manufacturing', 'mining industry', 'public sector', 'telecom', 'tourism', 'transport', 'utilities & energy'].each do |s|
  Sector.create!(name: s)
end

['American Indian or Alaska Native', 'Asian', 'Black or African American',
 'Native Hawaiian or Other Pacific Islander', 'White'].each do |race|
  Race.create!(name: race)
end

['HS Diploma', 'GED', '2 year degree', '4 year degree',
 'Masters Degree and above'].each do |e|
  Education.create!(name: e)
end
