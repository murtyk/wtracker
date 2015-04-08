# provides search services on Employer
# for searching employers, contacts
# or interested in trainees
class EmployerServices
  attr_reader :filters, :user
  def initialize(user, search_filters = {})
    @user = user
    @filters = search_filters
  end

  def employers_for_trainee_interaction
    return [] if name.blank?
    employers = search_by_name - employers_currently_interested_in_trainee
    employers.map do |employer|
      { id: employer.id,
        name: "#{employer.name} - #{employer.city_state || 'no address'}" }
    end
  end

  def search(no_includes = false)
    return [] unless search_parameters?
    return all_employers if filters[:all]
    return search_by_name unless name.blank?

    apply_filters(no_includes)
  end

  def apply_filters(no_includes)
    employers = all_employers(no_includes)
    employers = employers.in_counties(county_ids) unless county_ids.empty?
    employers = employers.in_sector(sector_id) if sector_id > 0
    unless employer_source_id.blank?
      employers = employers.where(employer_source_id: employer_source_id)
    end

    employers
  end

  def search_contacts
    return [] unless search_parameters?
    employer_ids = search(true).pluck(:id)
    user.employers.joins(:contacts)
      .select("contacts.id as id,
                    first || ' ' || last || '(' || employers.name || ')' as name,
                    employers.name as employer_name")
      .where("not contacts.email = '' and
                    not contacts.email is null and
                    employers.id in (?)", employer_ids)
      .order('employer_name, name')
  end

  private

  def all_employers(no_includes = false)
    return user.employers.order_by_name if no_includes
    user.employers.includes(:address, :sectors, :employer_notes, :contacts).order_by_name
  end

  def search_by_name
    user.employers.where('name ilike ?', name + '%') unless name.blank?
  end

  def employers_currently_interested_in_trainee
    (trainee && trainee.interested_employers) || []
  end

  def search_parameters?
    !filters.blank?
  end

  def trainee
    trainee_id > 0 && Trainee.find(trainee_id)
  end

  def trainee_id
    filters[:trainee_id].to_i
  end

  def name
    filters[:name]
  end

  def sector_id
    filters[:sector_id].to_i
  end

  def county_ids
    c_ids = [filters[:county_id]] if filters[:county_ids].blank?
    c_ids ||= filters[:county_ids]
    c_ids = c_ids.compact
    c_ids.delete('')
    c_ids
  end

  def source
    filters[:source]
  end

  def employer_source_id
    filters[:employer_source_id]
  end
end
