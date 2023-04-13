# frozen_string_literal: true

include UtilitiesHelper
# any trainee activities in the date range?
class TraineeActivity < DelegateClass(Trainee)
  attr_reader :start_date, :end_date

  def initialize(obj, start_date = nil, end_date = nil)
    super(obj)
    @start_date = start_date
    @end_date = end_date
  end

  def klass
    klasses.first
  end

  def klass_name
    klass_names.join(',') # from trainee
  end

  def klass_end_date
    klass && klass.end_date.to_s
  end

  def college_name_location
    klass&.college_name_location
  end

  def status
    return '' unless klass

    klass_trainee = KlassTrainee.where(trainee_id: id,
                                       klass_id: klass.id).first
    klass_trainee.nil? ? '' : KlassTrainee::STATUSES[klass_trainee.status]
  end

  def employer_interactions
    filter_by_update_date(trainee_interactions)
  end

  def notes
    filter_by_create_date(trainee_notes)
  end

  def job_lead_count
    filter_by_create_date(job_shared_tos).count
  end

  def valid_dates?
    !start_date.blank? && !end_date.blank?
  end

  def filter_by_create_date(objects)
    return objects unless valid_dates?

    objects.where('DATE(created_at) >= ? AND DATE(created_at) <= ? ',
                  start_date, end_date)
  end

  def filter_by_update_date(objects)
    return objects unless valid_dates?

    objects.where('DATE(updated_at) >= ? AND DATE(updated_at) <= ?',
                  start_date, end_date)
  end
end
