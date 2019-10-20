# employers with missing address
class EmployersWithApprenticesReport < Report
  attr_reader :employers
  def post_initialize(_params)
    employer_ids = Trainee.where.not(employer_id: nil).select(:employer_id)
    @employers = Employer.where(id: employer_ids).includes(apprentices: :mentor)
  end

  def title
    'Employers With Apprentices'
  end

  def selection_partial
    'none'
  end

  delegate :count, to: :employers
end
