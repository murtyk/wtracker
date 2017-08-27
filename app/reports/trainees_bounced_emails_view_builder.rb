# builds rows and headers for excel
class TraineesBouncedEmailsViewBuilder
  include Enumerable

  def header
    ['Name', 'Trainee ID', 'Email', 'Reason']
  end

  def build_row(trainee)
    [trainee.name,
     trainee.trainee_id,
     trainee.email,
     trainee.bounced_reason]
  end
end
