# frozen_string_literal: true

# decorator for klass event
class KlassEventDecorator < Draper::Decorator
  delegate_all
  attr_accessor :klass_interaction

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def date_and_name
    event_date_name = "#{event_date} - #{name}"

    unless cancelled?
      return "<p style='margin-left: 10px'>".html_safe +
             event_date_name +
             '</p>'.html_safe
    end

    "<p style='margin-left: 10px; color: red'>".html_safe +
      event_date_name +
      '</p>'.html_safe
  end

  def klass_interaction_status
    klass_interaction.status
  end

  def klass_interaction_id
    klass_interaction.id
  end

  def date
    event_date.to_s
  end

  def time
    return 'All Day' unless start_time_hr

    "#{format('%s:%02d%s', start_time_hr, start_time_min.to_i,
              start_ampm)} to #{format('%s:%02d%s', end_time_hr, end_time_min.to_i,
                                       end_ampm)}"
  end

  def edit_link_id
    "edit_klass_event_link#{id}"
  end

  def delete_link_id
    "destroy_klass_event_link#{id}"
  end

  def other_name
    return '' if ['class visit', 'site visit',
                  'information session'].include?(name.downcase)

    "<p>#{name}</p>".html_safe
  end

  def interactions_grouped_by_status
    KlassInteraction::STATUSES.map do |k, v|
      interactions = interactions_by_status(k)
      next if interactions.empty?

      data = OpenStruct.new
      data.status = k
      data.header = "<p><strong>#{v} " \
                    "(#{interactions.count})</strong></p>".html_safe
      data.klass_interactions = interactions
      data
    end.compact
  end

  def interactions_by_status(status)
    klass_interactions
      .select { |ki| ki.klass_event_id == id && ki.status == status }
  end

  def cancelled?
    kis = klass_interactions.select { |ki| ki.klass_event_id == id }
    kis.size == 1 && kis.first.status == 4
  end

  def employer_name
    first_employer.try(:name)
  end

  def first_employer
    klass_interactions.each do |ki|
      return ki.employer if ki.employer
    end
    nil
  end
end
