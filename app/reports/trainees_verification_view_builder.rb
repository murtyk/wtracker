# builds rows and headers for excel
class TraineesVerificationViewBuilder
  include Enumerable

  def header
    ['Name', 'Trainee ID', 'Email', 'Mobile', 'Street', 'City', 'Zip', 'TAPO ID','Funding Source', 'Navigator', 'Placement Status',
     'UI Claim Verified On', 'UI Verification Notes', 'Disabled On', 'Disabled Notes', 'DOB', 'State',
     'County' ]
  end

  def build_row(trainee)
    [trainee.name,
     trainee.trainee_id,
     trainee.email ? trainee.email.remove("<br>") : nil,
     trainee.mobile_no ? trainee.mobile_no.remove("<br>") : nil,
     trainee.line1,
     trainee.city,
     trainee.zip,
     trainee.id,
     trainee.funding_source_name,
     trainee.navigator_name,
     trainee.placement_status,
     trainee.ui_claim_verified_on,
     trainee.ui_verification_notes,
     trainee.disabled_date,
     trainee.disabled_notes,
     trainee.dob,
     trainee.state,
     trainee.county_name]
  end
end
