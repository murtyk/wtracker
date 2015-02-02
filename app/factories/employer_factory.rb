# 1. create from a job search
# 2. user entered on browser
class EmployerFactory
  ADDR_ATTR_LIST = [:line1, :city, :zip, :county, :latitude, :longitude]

  def self.create_from_job_search(current_user, params)
    sector_ids = params[:sector_ids].split(',').map { |s| s.to_i }
    current_user.last_sectors_selected = sector_ids

    job_search = JobSearch.find(params[:job_search_id])
    source = "job search - #{job_search.keywords} - #{job_search.location}"

    opero_company_id = params[:info][:opero_company_id].to_i
    if opero_company_id > 0
      employer, exists, error = create_from_opero(opero_company_id,
                                                  source,
                                                  sector_ids)
    else
      employer, exists, error = create_from_gi(params[:info].clone,
                                               source,
                                               sector_ids)
    end

    job_search.analyzer.update_company_employer(employer) unless error

    [employer, exists, error]
  end

  def self.create_from_opero(opero_company_id, source, sector_ids)
    oc = OperoCompany.find(opero_company_id)
    employer = Employer.existing_employer(oc.name, oc.latitude, oc.longitude)
    return [employer, true] if employer

    address_attributes = build_address_attributes_from_oc(oc)

    begin
      employer = Employer.new(name: oc.name, source: source,
                              phone_no: oc.phone_no, website: oc.website,
                              address_attributes: address_attributes,
                              sector_ids: sector_ids)
      employer.save
    rescue StandardError => e
      error = e
    end

    [employer, false, error]
  end

  def self.build_address_attributes_from_oc(oc)
    address_attributes = {}
    ADDR_ATTR_LIST.each do |attr|
      address_attributes[attr] = oc.send(attr)
    end
    address_attributes[:state] = oc.state_code
    address_attributes
  end

  def self.create_from_gi(gi, source, sector_ids)
    emp = Employer.existing_employer(gi[:name], gi[:latitude], gi[:longitude])
    return [emp, true] if emp

    error = nil
    begin
      emp = build_from_gi(gi, source, sector_ids)
      emp.save
    rescue StandardError => e
      error = e
    end

    [emp, false, error]
  end

  def self.build_from_gi(gi, source, sector_ids)
    address_attributes = build_address_attributes_from_gi(gi)
    Employer.new(name: gi[:name], source: source, phone_no: gi[:phone_no],
                 website: gi[:website], sector_ids: sector_ids,
                 address_attributes: address_attributes)
  end

  def self.create_employer(current_user, params)
    city = params[:address_attributes][:city]
    params.delete(:address_attributes) if city.blank?
    employer = Employer.new(params)

    saved = false
    if employer.duplicate?
      employer.errors.add(:name, "duplicate employer #{params[:name]}")
    else
      saved = save_employer(employer, params, current_user)
    end

    employer.build_address if !saved && employer.address.nil?

    [employer, saved]
  end

  def self.save_employer(employer, params, current_user)
    begin
      # sector_ids = clean_sector_ids(params, current_user)
      saved = employer.save
    rescue StandardError => e
      error_message = e.to_s
      if error_message.include?('address error:')
        employer.errors.add(:address_attributes,
                            error_message.gsub('address error:', ''))
      else
        employer.errors.add(:base, error_message)
      end
    end
    saved
  end

  def self.update_employer(all_params)
    employer = Employer.find(all_params[:id])

    params = all_params.clone[:employer]
    no_address = clean_address(params)

    saved, error_message = update(params, employer, no_address)

    employer.build_address if !saved && employer.address.nil?

    [saved, employer, error_message]
  end

  def self.build_address_attributes_from_gi(gi)
    address_attributes = {}
    ADDR_ATTR_LIST.each do |attr|
      address_attributes[attr] = gi[attr]
    end
    address_attributes[:state] = gi[:state_code]
    address_attributes
  end

  def self.clean_address(params)
    return nil unless params[:address_attributes][:city].blank?
    params.delete(:address_attributes)
    true
  end

  def clean_sector_ids(params, current_user)
    sector_ids = params[:sector_ids]
    sector_ids.delete('')
    current_user.last_sectors_selected = sector_ids.map(&:to_i)
    sector_ids
  end

  def self.update(params, employer, no_address)
    saved = false
    begin
      ActiveRecord::Base.transaction do
        employer.update_attributes(params)
        employer.address.destroy if no_address && employer.address
        if employer.duplicate?(no_address)
          employer.errors[:name] = 'duplicate'
          fail "duplicate employer #{params[:name]}"
        end
        saved = true
      end
    rescue StandardError => e
      error_message = e.to_s
    end
    [saved, error_message]
  end
end
