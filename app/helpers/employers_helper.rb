require 'ostruct'
# for employer stats
# by county, sector and source
module EmployersHelper
  def employer_analysis
    analysis = OpenStruct.new
    analysis.by_counties      = employer_county_analysis
    analysis.by_sectors       = employer_sector_analysis
    analysis.by_source        = employer_source_analysis
    analysis.address_less     = address_less_analysis
    analysis.total            = Employer.count
    analysis
  end

  def employer_county_analysis
    items = []
    employer_county_counts.each do |row|
      item = OpenStruct.new
      item.count = row[0]
      item.name  = "#{row[2]}-#{row[1]}"
      item.id    = row[3]
      items.push item
    end
    items
  end

  def employer_sector_analysis
    items = []
    employer_sector_counts.each do |row|
      item = OpenStruct.new
      item.count = row[0]
      item.name  = row[1]
      item.id    = row[2]
      items.push item
    end
    items
  end

  def employer_source_analysis
    items = []
    employer_source_counts.each do |row|
      item = OpenStruct.new
      item.count = row[0]
      item.name  = row[1]
      items.push item
    end
    items
  end

  def address_less_analysis
    items = []
    address_less_employers.each do |row|
      item = OpenStruct.new
      item.id    = row[0]
      item.name  = row[1]
      items.push item
    end
    items
  end

  def employer_counties_for_selection
    employer_county_counts.map { |row| ["#{row[2]} - #{row[1]} (#{row[0]}) ", row[3]] }
  end

  def employer_county_counts
    sql_query(
      %{
        SELECT COUNT(*) AS count, counties.name as name,
        addresses.state as state, county_id
        FROM addresses inner join counties
        on counties.id = addresses.county_id
        where addressable_type = 'Employer'
        and account_id = #{Account.current_id}
        GROUP BY state, county_id, name ORDER BY state, county_id, name
        }
    )
  end

  def employer_sector_counts
    sql_query(
      %{
        select count(*) as count, sectors.name as name, sectors.id as id
        from employer_sectors inner join sectors
        on sectors.id = employer_sectors.sector_id
        and employer_sectors.account_id = #{Account.current_id}
        group by name, sectors.id order by sectors.name
        }
    )
  end

  def employer_sectors_for_selection
    employer_sector_counts.map { |row| [row[1] + ' - ' + row[0], row[2]] }
  end

  def employer_source_counts
    sql_query(
      %{
        SELECT COUNT(source) AS count_source, source AS source
        FROM employers
        WHERE employers.account_id = #{Account.current_id}
        GROUP BY source ORDER BY source
        }
    )
  end

  def employer_sources_for_selection
    sources = if current_user.admin_access?
                EmployerSource.all
              else
                current_user.employer_sources
              end
    counts = Employer.where(employer_source_id: sources.pluck(:id))
                     .group(:employer_source_id).count
    sources.map { |es| [es.name + ' - ' + counts[es.id].to_s, es.id] }
  end

  def address_less_employers
    sql_query(
      %(
        SELECT employers.id, employers.name FROM employers
        LEFT OUTER JOIN addresses
        ON employers.id = addresses.addressable_id
        and addresses.addressable_type = 'Employer'
        where employers.account_id = #{Account.current_id}
        and addresses.id is null
        )
    )
  end

  def sql_query(sql)
    pg_result = ActiveRecord::Base.connection.execute(sql)
    pg_result.values
  end
end
