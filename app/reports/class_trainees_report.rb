class ClassTraineesReport < TraineesDetailsReport
  # Report class expects klass_ids where as for this report we get :klass_id
  def initialize(user, params = nil)
    if params
      parameters = params.clone
      parameters[:klass_ids] = [params[:klass_id]]
      super(user, parameters)
    else
      super(user, params)
    end
  end

  def klass
    klass_ids && klasses.first
  end

  def klass_id
    klass_ids && klass_ids.first
  end

  def trainees
    return [] if @klasses_and_trainees.blank?
    @klasses_and_trainees[0][1]
  end
end
