include UtilitiesHelper
# this is mainly designed for grant where applicants can apply
class TraineePlacement < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  # ex: .where("info @> (? => ?)", :job_title, 'Analyst')
  FIELDS = %w(company_name address_line1 address_line2 city state zip phone_no
              salary job_title start_date reported_date placement_type)

  FIELDS.each do |field|
    attr_accessible field
  end

  validate :validate_data

  belongs_to :account
  belongs_to :trainee

  after_initialize :init_fields
  before_create :assign_reported_date

  def date_field?(field)
    FIELD_TYPES[field.to_sym] == :date
  end

  def collection_field?(field)
    [:state_code, :placement_type_code].include? FIELD_TYPES[field.to_sym]
  end

  def field_collection(field)
    case FIELD_TYPES[field.to_sym]
    when :state_code
      State.pluck(:code)
    when :placement_type_code
      placement_types
    end
  end

  def default_value(field)
    return unless FIELD_TYPES[field.to_sym] == :placement_type_code
    0
  end

  def required?(field)
    field.to_sym != :address_line2
  end

  def fields
    FIELDS - ['reported_date']
  end

  def mask_fields
    []
    # [[:phone_no, "99/99/9999", "mm/dd/yyyy"]]
  end

  def address
    "#{address_line1} #{address_line2} <br> #{city} #{state} #{zip}".html_safe
  end

  def placement_type_description
    placement_types[placement_type.to_i][0]
  end

  def placement_types
    [['30 Hours or more (FT)', 0], ['29 hours or less (PT)', 1]]
  end

  def phone_number
    phone_no
  end

  def details
    "<strong>#{created_at.to_date} - #{company_name}</strong>" \
    "<br>#{salary}#{job_title}#{start_date}<br>Type: #{placement_type_description}"
  end

  private

  FIELD_TYPES = { state:         :state_code,
                  phone_no:      :phone_number,
                  start_date:    :date,
                  reported_date: :date,
                  placement_type: :placement_type_code }

  def init_fields
    FIELDS.each do |field|
      self.class.send(:store_accessor, :info, field)
      field_type = FIELD_TYPES[field.to_sym]
      next unless field_type
      case field_type
      when :boolean
        create_boolean_method(field)
      when :date
        create_method(field) do
          value = info[field]
          return nil unless value
          opero_str_to_date(value)
        end
      end
    end
  end

  def create_boolean_method(field)
    create_method(field) do
      value = info[field]
      return (value == 'true') if %w(true false).include? value
      value
    end
  end

  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end

  def validate_data
    valid = true
    fields.each do |field|
      if required?(field) && send(field).blank?
        errors.add(field, "can't be blank")
        valid = false
      end
    end
    valid
  end

  def assign_reported_date
    @reported_date = Date.today.to_s
  end
end
