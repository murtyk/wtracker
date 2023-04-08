# frozen_string_literal: true

# for generating klasses
module KlassesHelper
  def create_klasses(n = 1, trainees_per_klass = 0)
    seq = get_klasses_ids.count
    start_new_klass_seq = seq + 1
    n.times do
      seq += 1
      visit '/klasses'
      page.first(:css, '#new_klass_link').click
      fill_in 'Name', with: "Engineering#{seq}"
      click_button 'Save'
    end

    return unless trainees_per_klass > 0

    get_kasses_with_seq_number(start_new_klass_seq).each do |klass|
      create_trainees(trainees_per_klass, klass)
    end
  end

  def destroy_klasses
    allow_any_instance_of(KlassPolicy).to receive('destroy?')
      .and_return(true)

    visit '/klasses'

    sleep 0.2

    get_klasses_ids.each do |klass_id|
      AlertConfirmer.accept_confirm_from do
        click_link "destroy_klass_#{klass_id}_link"
      end
      wait_for_ajax
    end
  end

  def get_klasses_ids
    get_klasses.pluck(:id)
  end

  def get_klasses
    Account.current_id = 1
    Grant.current_id = 1
    grant = Grant.find(1)
    grant.klasses.where('klasses.name ilike ?', 'Engineering%')
  end

  def get_kasses_with_seq_number(start_seq = 1)
    get_klasses.select { |klass| klass.name >= "Engineering#{start_seq}" }
  end

  def get_an_existing_klass
    Account.current_id = 1
    Grant.current_id = 1
    grant = Grant.find(1)
    grant.klasses.first
  end

  def destroy_all_created
    destroy_trainees
    destroy_klasses
    destroy_employers
  end
end
