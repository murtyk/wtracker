class DailyKlassTraineeStatus
  def perform
    k_ids = Klass.unscoped.where('end_date < ?', Date.today).pluck :id
    kt_ids = KlassTrainee.unscoped.where(klass_id: k_ids, status: 1).pluck(:id)
    KlassTrainee.unscoped.where(id: kt_ids).update_all(status: 2)
  end
end
