# frozen_string_literal: true

# employers with missing address
class EmployersNoAddressReport < Report
  attr_reader :employers

  def post_initialize(_params)
    joins_sql = "LEFT OUTER JOIN addresses on
                 addresses.addressable_id = employers.id and
                 addresses.addressable_type = 'Employer'"
    @employers = user.employers.joins(joins_sql)
                     .where('addresses.addressable_id is null')
  end

  def title
    'Employers With Missing Address'
  end

  def selection_partial
    'none'
  end

  delegate :count, to: :employers
end
