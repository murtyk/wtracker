module KlassTraineesHelper
  def get_klass_trainees(t_ids = nil)
    Account.current_id = 1
    return KlassTrainee.where(trainee_id: t_ids) if t_ids
    KlassTrainee.where(klass_id: get_klasses_ids)
  end

  def get_klass_trainee_ids(t_ids = nil)
    get_klass_trainees(t_ids).pluck(:id)
  end
end
