# standard dashboard for grants such as Manufacturing
# No Applicants.
# Show programs, classes grouped by status, trainee counts by status
class DashboardStandard
  # need this for link_to
  include ActionView::Helpers::UrlHelper
  attr_reader :data, :buttons, :button_class, :xls

  def initialize(xls = false)
    @xls = xls
    generate_buttons
    generate_data
  end

  def generate_buttons
    @button_class = 'klass_filter btn btn-flat btn-small btn-primary'
    @buttons = [
        { id: '1_scheduled_klasses_button', label: 'Scheduled' },
        { id: '2_ongoing_klasses_button'  , label: 'Ongoing' },
        { id: '3_completed_klasses_button', label: 'Completed' },
        { id: '0_all_klasses_button'      , label: 'All' }
      ]
  end

  def generate_data
  end

  def download_button?
    Klass.any?
  end

  def xls?
    @xls
  end
end
