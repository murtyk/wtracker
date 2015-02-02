# employers with missing address
class EmployersNoAddressReport < Report
  attr_reader :employers
  def post_initialize(params)
    joins_sql = "LEFT OUTER JOIN addresses on
                 addresses.addressable_id = employers.id and
                 addresses.addressable_type = 'Employer'"
    @employers = Employer.joins(joins_sql)
                         .where('addresses.addressable_id is null')
  end

  def count
    employers.count
  end
end
