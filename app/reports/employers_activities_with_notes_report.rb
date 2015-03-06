include UtilitiesHelper
# employers with notes activity in the date range
class EmployersActivitiesWithNotesReport < Report
  def post_initialize(params)
    return unless params
    @employers = Employer.includes(:employer_notes).where(id: employer_ids)
  end

  def title
    'Employers with Notes'
  end

  def selection_partial
    'employers_activities_selection'
  end

  delegate :count, to: :employers

  def employers
    @employers || []
  end

  def employer_ids
    return EmployerNote.pluck(:employer_id).uniq if @include_all_dates
    EmployerNote.where('DATE(created_at) >= ? AND DATE(created_at) <= ?',
                       start_date, end_date).pluck(:employer_id).uniq
  end
end
