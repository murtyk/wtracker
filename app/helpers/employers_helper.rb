# frozen_string_literal: true

# for employer stats
# by county, sector and source
module EmployersHelper
  def employer_analysis
    OpenStruct.new(
      by_counties: employer_county_analysis,
      by_sectors: employer_sector_analysis,
      by_source: employer_source_analysis,
      address_less: address_less_analysis,
      total: employers_count
    )
  end

  def employers_count
    Employer.where(id: employer_ids).count
  end

  def address_less_analysis
    address_less_employers.map do |row|
      OpenStruct.new(id: row[0], name: row[1])
    end
  end

  def employer_counties_for_selection
    employer_county_counts.map do |(id, name, state), count|
      ["#{state} - #{name} (#{count})", id]
    end
  end

  def employer_county_analysis
    employer_county_counts.map do |(id, name, state), count|
      OpenStruct.new(id: id, name: "#{name}-#{state}", count: count)
    end
  end

  def employer_county_counts
    Address.where(addressable_id: employer_ids)
           .where(addressable_type: 'Employer')
           .order(:county, :state)
           .group(:county_id, :county, :state)
           .count
  end

  def employer_sector_analysis
    employer_sector_counts.map do |(id, name), count|
      OpenStruct.new(id: id, name: name, count: count)
    end
  end

  def employer_sectors_for_selection
    employer_sector_counts.map do |(id, name), count|
      ["#{name} - #{count}", id]
    end
  end

  def employer_sector_counts
    EmployerSector.joins(:sector)
                  .where(employer_id: employer_ids)
                  .order('sectors.name')
                  .group(['sectors.id', 'sectors.name'])
                  .count
  end

  def employer_source_analysis
    employer_source_counts.map do |(id, name), count|
      OpenStruct.new(id: id, name: name, count: count)
    end
  end

  def employer_sources_for_selection
    employer_source_counts.map do |(id, name), count|
      ["#{name} - #{count}", id]
    end
  end

  def employer_source_counts
    Employer.joins(:employer_source)
            .where(employers: { id: employer_ids })
            .order('employer_sources.name')
            .group(['employer_source_id', 'employer_sources.name'])
            .count
  end

  def employer_source_ids
    employer_sources.pluck(:id)
  end

  def employer_sources
    return EmployerSource.order(:name) if current_user.admin_access?

    current_user.employer_sources.order(:name)
  end

  def employer_ids
    emps = Employer.joins(:employer_source)
    emps = if current_grant.scoped_employers
             emps.where(employer_sources: { grant_id: current_grant.id })
           else
             emps.where(employer_sources: { grant_id: nil })
           end
    emps.pluck(:id)
  end

  def address_less_employers
    emp_with_address_ids = Address.where(addressable_type: 'Employer')
                                  .where(addressable_id: employer_ids)
                                  .pluck(:addressable_id)

    current_user.employers
                .where(id: employer_ids - emp_with_address_ids)
                .pluck(:id, :name)
  end

  def employer_link_or_name(emp)
    return emp.name unless current_user.admin_access? ||
                           employer_sources.include?(emp.employer_source)

    link_to(emp.name, emp)
  end
end
