class Api::V1::LeadsQueuesController < Api::V1::ApiBaseController
  before_action :authenticate_with_token!

  def show
    lq = next_item

    if lq
      render json: lq, status: 200, root: false
    else
      shutdown_tapo_workers
      render json: { errors: 'No Jobs' }, status: 200
    end
  end

  def update
    lq = LeadsQueue.find params[:id]
    trainee = Trainee.unscoped.find lq.trainee_id
    Account.current_id = trainee.account_id
    trainee.auto_shared_jobs.create(params[:leads]) if params[:leads]
    lq.update(status: 3)
    render json: {}, status: 200
  end

  def next_item
    lq = LeadsQueue.pending.first
    while lq
      LeadsQueue.transaction do
        lq = LeadsQueue.lock(true).find lq.id
        if lq.pending?
          lq.start
          return lq
        end
      end
      lq = LeadsQueue.pending.first
    end
    lq
  end

  def shutdown_tapo_workers
    return if Rails.env.development? || Rails.env.test?
    HerokuControl.delay.auto_leads_workers_down
  end
end
