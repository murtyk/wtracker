# decorator for program
class ProgramDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end
  def klasses_order
    'colleges.name, klasses.start_date, klasses.end_date'
  end

  def user_klasses(user)
    return program_klasses if user.admin_access? || user.grants.include?(grant)
    assigned_klasses(user)
  end

  def program_klasses
    klasses
      .includes(:college, :klass_certificates, :klass_category)
      .order(klasses_order)
      .decorate
  end

  def assigned_klasses(user)
    user.klasses
      .includes(:college, :klass_certificates)
      .where(program_id: id)
      .order(klasses_order)
      .decorate
  end

  # below are for dashboard
  def scheduled_classes
    object.scheduled_classes.map(&:decorate)
  end

  def ongoing_classes
    object.ongoing_classes.map(&:decorate)
  end

  def completed_classes
    object.completed_classes.map(&:decorate)
  end

  def query_classes(predicate)
    klasses.joins(:college)
      .where(predicate)
      .order('colleges.name, start_date desc, end_date desc')
      .decorate
  end

  def classes_by_status
    cs = []
    cs << ['scheduled_classes', scheduled_classes] if scheduled_classes.any?
    cs << ['ongoing_classes',   ongoing_classes] if ongoing_classes.any?
    cs << ['completed_classes', completed_classes] if completed_classes.any?
    cs
  end

  def enrolled_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.enrolled_count.to_i }.inject(:+)
  end

  def dropped_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.dropped_count.to_i }.inject(:+)
  end

  def completed_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.completed_count.to_i }.inject(:+)
  end

  def continuing_education_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.continuing_education_count.to_i }.inject(:+)
  end

  def placed_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.placed_count.to_i }.inject(:+)
  end

  def not_placed_count(klass_status)
    classes = send(klass_status)  # don't use klasses since it is a member
    classes.map { |klass| klass.not_placed_count.to_i }.inject(:+)
  end

  def placement_rate(klass_status)
    # completed is our target for placement, exclude continuing education

    dividend = placed_count(klass_status) + continuing_education_count(klass_status)
    divider  = divisor(klass_status)
    divider > 0 ? (dividend.to_f * 100 / divider).round(0).to_s + '%' : ''
  end

  def divisor(klass_status)
    not_placed_count(klass_status) +
      placed_count(klass_status) +
      continuing_education_count(klass_status)
  end
end
