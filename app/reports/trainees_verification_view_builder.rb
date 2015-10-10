# builds rows and headers for excel
class TraineesVerificationViewBuilder
  include Enumerable

  def header
    ['Name', 'TAPO ID', 'DOB', 'Trainee ID', 'Address', 'County', 'Email',
     'Mobile', 'Funding Source', 'Navigator', 'Placement Status']
  end

  def build_row(trainee)
    [trainee.name,
     trainee.id,
     trainee.dob,
     trainee.trainee_id,
     trainee.formatted_address,
     trainee.county_name,
     trainee.email,
     trainee.mobile_no,
     trainee.funding_source_name,
     trainee.navigator_name,
     trainee.placement_status]
  end
end
