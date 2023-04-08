# frozen_string_literal: true

# trainees info in ONE selected class
class ClassTraineesReport < TraineesDetailsReport
  # Report class expects klass_ids where as for this report we get :klass_id
  def klass
    klass_id && Klass.find(klass_id)
  end

  def count
    trainees.count
  end

  def trainees
    return [] unless klass_id

    klass.trainees.includes(:funding_source, :home_address)
  end

  def title
    'Class Trainees'
  end

  def selection_partial
    'single_class_selection'
  end
end
