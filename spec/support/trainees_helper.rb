# frozen_string_literal: true

# for creating trainee objects
module TraineesHelper
  def create_trainees(n = 1, klass = nil, seq = nil)
    klass ||= get_an_existing_klass
    klass_label = klass.to_label

    seq ||= get_trainee_ids.count
    seq = seq.to_i

    n.times do
      seq += 1
      create_trainee(seq, klass_label)
    end

    get_trainee_ids
  end

  def create_trainee(seq, klass_label)
    visit '/trainees/new'
    fill_in 'First Name', with: "First#{seq}"
    fill_in 'Last Name', with: "Last#{seq}"
    fill_in 'Email', with: "First#{seq}.Last#{seq}@mail.com"
    select(klass_label, from: 'trainee_klass_ids')
    click_button 'Save'
  end

  def get_trainee_ids
    get_trainees.order(:id).pluck(:id)
  end

  def get_trainee_services_ids
    trainee_ids = get_trainee_ids
    TraineeService.where(trainee_id: trainee_ids).pluck(:id)
  end

  def get_trainees
    Account.current_id = 1
    Grant.current_id = 1
    Trainee.where('last ilike ?', 'Last%')
  end

  def get_trainee_interaction_ids
    trainee_ids = get_trainee_ids
    TraineeInteraction.where(trainee_id: trainee_ids).pluck(:id)
  end

  def get_trainee_notes_ids
    trainee_ids = get_trainee_ids
    TraineeNote.where(trainee_id: trainee_ids).pluck(:id).sort
  end

  def get_ui_verified_notes_ids
    trainee_ids = get_trainee_ids
    UiVerifiedNote.where(trainee_id: trainee_ids).pluck(:id).sort
  end

  def destroy_trainees
    allow_any_instance_of(TraineePolicy).to receive('destroy?')
      .and_return(true)

    visit '/trainees'

    fill_in 'filters_name', with: 'Last'
    click_on 'Find'
    sleep 0.2

    trainees_count.times do
      AlertConfirmer.accept_confirm_from do
        find('a.btn-danger', match: :first).click
      end
      wait_for_ajax
    end
  end

  def trainees_count
    Account.current_id = 1
    Grant.current_id = 1
    Trainee.where('last ilike ?', 'Last%').count
  end
end
