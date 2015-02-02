module InteractionsMixins
  def trainee_interactions_by_status
    status_tis = {}
    TraineeInteraction::STATUSES.keys.each do |st|
      tis = trainee_interactions.where(status: st)
      status_tis[st] = tis if tis.any?
    end
    status_tis
  end
end
