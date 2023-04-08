# frozen_string_literal: true

# builds rows and headers for excel
class TraineesBouncedEmailsViewBuilder
  include Enumerable

  def header
    ['Name', 'TAPO ID', 'Email', 'Reason']
  end

  def build_row(trainee)
    [trainee.name,
     trainee.id,
     trainee.email,
     trainee.bounced_reason]
  end
end
