# builds rows and headers for excel
class TraineesNearByEmployersViewBuilder
  include Enumerable
  attr_reader :data, :max_contacts
  def initialize(data, max_contacts = 3)
    @data = data
    @max_contacts = max_contacts
  end

  def header
    ['Class', 'Trainee', 'Email', 'Phone', 'Address', 'Employer', 'Address',
     max_contacts.times.map { |n| "Contact #{n + 1}" }
    ].flatten
  end

  def build_row(trainee, employer, contacts)
    row = [klass_name,
           trainee_data(trainee),
           employer_data(employer, contacts)].flatten

    return row unless  max_contacts > contacts.count
    row + [''] * (max_contacts - contacts.count)
  end

  def excel_format(s)
    l_br = "\x0A"
    s = s.gsub('<b>', '').gsub('</b>', '')
    s.split('<br>').join(l_br)
  end

  def klass_name
    @data.klass.name
  end

  def trainee_data(trainee)
    [trainee.name,
     trainee.email.gsub('<br>', ''),
     trainee.land_no,
     excel_format(trainee.home_address.to_s_for_view)]
  end

  def employer_data(employer, contacts)
    l_br = "\x0A"
    [employer.name + l_br + 'Source: ' + employer.employer_source_name,
     excel_format(employer.address.to_s_for_view),
     format_contacts(contacts)]
  end

  def format_contacts(cs)
    cs.map { |contact| excel_format(contact.details) }
  end
end
