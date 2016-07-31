# standard dashboard for grants such as Manufacturing
# No Applicants.
# Show programs, classes grouped by status, trainee counts by status
class StandardMetrics < DashboardMetrics
  # need this for link_to
  include ActionView::Helpers::UrlHelper
  attr_reader :programs, :buttons, :button_class, :enrolled_counts, :kt_status_counts, :xls

  def initialize
    generate_buttons
    generate_data
  end

  def generate_buttons
    @button_class = 'klass_filter btn btn-flat btn-small btn-primary'
    @buttons = [
      { id: '1_scheduled_klasses_button', label: 'Scheduled' },
      { id: '2_ongoing_klasses_button', label: 'Ongoing' },
      { id: '3_completed_klasses_button', label: 'Completed' },
      { id: '0_all_klasses_button', label: 'All' }
    ]
  end

  def generate_data
    @programs = Program.includes(:scheduled_classes,
                                 :ongoing_classes,
                                 :completed_classes).decorate
    @template = 'standard_metrics/index'

    init_counts
  end

  def init_counts
    @enrolled_counts = KlassTrainee
                         .where(klass_id: Klass.select(:id))
                         .group(:klass_id)
                         .count

    @kt_status_counts = KlassTrainee
                          .where(klass_id: Klass.select(:id))
                          .group(:klass_id, :status)
                          .count
  end

  def klass_counts(k_id)
    {
      enrolled:  enrolled_count(k_id),
      dropped:   dropped_count(k_id),
      completed: completed_count(k_id),
      continuing_education: continuing_education_count(k_id),
      not_placed: not_placed_count(k_id),
      placed: placed_count(k_id),
      placement_rate: placement_rate(k_id)
    }
  end

  def enrolled_count(k_id)
    enrolled_counts[k_id].to_i
  end

  def dropped_count(k_id)
    kt_status_counts[[k_id, 3]].to_i
  end

  def continuing_education_count(k_id)
    kt_status_counts[[k_id, 5]].to_i
  end

  def placed_count(k_id)
    kt_status_counts[[k_id, 4]].to_i
  end

  def not_placed_count(k_id)
    kt_status_counts[[k_id, 2]].to_i # still in completed status waiting for placement
  end

  def completed_count(k_id)
    # subtract dropped and still in enrolled status ones from total
    enrolled_count(k_id) - kt_status_counts[[k_id, 1]].to_i - dropped_count(k_id)
  end

  def placement_rate(k_id)
    # continuing education and placed together is our target for placement
    dividend = placed_count(k_id) + continuing_education_count(k_id)
    divisor = not_placed_count(k_id) + placed_count(k_id) + continuing_education_count(k_id)
    divisor > 0 ? (dividend.to_f * 100 / divisor).round(0).to_s + '%' : ''
  end

  def klass_ids
    @klass_ids ||= Klass.pluck(:id).sort
  end

  # below is for program level counts
  def program_counts(program, klass_state)
    k_ids = program.send(klass_state).map(&:id)

    counts = {
      enrolled:  program_enrolled_count(k_ids),
      dropped:   program_dropped_count(k_ids),
      completed: program_completed_count(k_ids),
      continuing_education: program_continuing_education_count(k_ids),
      not_placed: program_not_placed_count(k_ids),
      placed: program_placed_count(k_ids)
    }

    dividend = counts[:placed] + counts[:continuing_education]
    divisor = counts[:not_placed] + counts[:placed] + counts[:continuing_education]
    rate = divisor > 0 ? (dividend.to_f * 100 / divisor).round(0).to_s + '%' : ''

    counts.merge(placement_rate: rate)
  end


  def program_enrolled_count(k_ids)
    k_ids.map{|k_id| enrolled_count(k_id)}.inject(:+)
  end

  def program_dropped_count(k_ids)
    k_ids.map{|k_id| dropped_count(k_id)}.inject(:+)
  end

  def program_completed_count(k_ids)
    k_ids.map{|k_id| completed_count(k_id)}.inject(:+)
  end

  def program_continuing_education_count(k_ids)
    k_ids.map{|k_id| continuing_education_count(k_id)}.inject(:+)
  end

  def program_not_placed_count(k_ids)
    k_ids.map{|k_id| not_placed_count(k_id)}.inject(:+)
  end

  def program_placed_count(k_ids)
    k_ids.map{|k_id| placed_count(k_id)}.inject(:+)
  end

  def download_button?
    Klass.any?
  end
end
