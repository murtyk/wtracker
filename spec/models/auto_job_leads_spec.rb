require 'rails_helper'

describe AutoJobLeads do
  before :each do
    #mock trainee
    t1 = double('Trainee', 'not_placed?' => false,
                           'incumbent?' => false) # placed
    t2 = double('Trainee', 'not_placed?' => true,
                           'opted_out_from_auto_leads?' => true,
                           'incumbent?' => false)
    t3 = double('Trainee', 'not_placed?' => true,
                           'opted_out_from_auto_leads?' => false,
                           'valid_profile?' => true,
                           'incumbent?' => false)
    t4 = double('Trainee', 'not_placed?' => true,
                           'opted_out_from_auto_leads?' => false,
                           'valid_profile?' => false,
                           'job_search_profile' => true,
                           'incumbent?' => false)
    t5 = double('Trainee', 'not_placed?' => true,
                           'opted_out_from_auto_leads?' => false,
                           'valid_profile?' => false,
                           'job_search_profile' => false,
                           'valid_email?' => true,
                           'incumbent?' => false)


    #mock grant
    grant = double('Grant', account_id: 1,
        id: 1,
        account_name: 'Account Name',
        name: 'Grant Name',
        'email_messages_defined?' => true,
        not_disabled_trainees: [t1,t2,t3, t4],
        trainees: [t1,t2,t3,t4,t5],
        'auto_job_leads?' => true,
        'trainee_applications?' => false)

    allow(Grant).to receive_message_chain("unscoped.where.load") { [grant] }

    # stub methods
    allow_any_instance_of(AutoJobLeads).to receive(:search_and_send_jobs)
      .and_return(5)
    allow_any_instance_of(AutoJobLeads).to receive(:notify_grant_status)
      .and_return(true)
    allow_any_instance_of(AutoJobLeads).to receive(:notify)
      .and_return(true)
  end

  it 'returns vaild statuses', skip: true do
    ajl = AutoJobLeads.new
    ajl.perform
    statuses = ajl.statuses
    expect(statuses.count).to eq(1)
    expect(statuses[0].trainee_job_leads.count).to eq(1)
  end
end
