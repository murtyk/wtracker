# 1. create from a job search
# 2. user entered on browser
class EmployerFactory
  ADDR_ATTR_LIST = [:line1, :city, :zip, :county, :latitude, :longitude]

  def self.create_from_job_search(current_user, params)
    sector_ids, employer_source_id, opero_company_id =
                          parse_js_params(current_user, params)

    employer, exists, error =
            if opero_company_id > 0
              create_from_opero(opero_company_id, employer_source_id, sector_ids)
            else
              create_from_gi(params[:info].clone, employer_source_id, sector_ids)
            end

    job_search = JobSearch.find(params[:job_search_id])
    job_search.analyzer(current_user).update_company_employer(employer) unless error

    [employer, exists, error]
  end

  def self.parse_js_params(current_user, params)
    sector_ids = params[:sector_ids].split(',').map(&:to_i)
    current_user.last_sectors_selected = sector_ids
    employer_source_id = current_user.default_employer_source_id
    opero_company_id = params[:info][:opero_company_id].to_i

    [sector_ids, employer_source_id, opero_company_id]
  end

  def self.create_from_opero(opero_company_id, employer_source_id, sector_ids)
    oc = OperoCompany.find(opero_company_id)
    employer = Employer.existing_employer(oc.name, employer_source_id,
                                          oc.latitude, oc.longitude)
    return [employer, true] if employer

    address_attributes = build_address_attributes_from_oc(oc)

    begin
      employer = Employer.new(name: oc.name, employer_source_id: employer_source_id,
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

  def self.create_from_gi(gi, employer_source_id, sector_ids)
    emp = Employer.existing_employer(gi[:name],
                                     employer_source_id, gi[:latitude], gi[:longitude])
    return [emp, true] if emp

    error = nil
    begin
      emp = build_from_gi(gi, employer_source_id, sector_ids)
      emp.save
    rescue StandardError => e
      error = e
    end

    [emp, false, error]
  end

  def self.build_from_gi(gi, employer_source_id, sector_ids)
    address_attributes = build_address_attributes_from_gi(gi)
    Employer.new(name: gi[:name], employer_source_id: employer_source_id,
                 phone_no: gi[:phone_no],
                 website: gi[:website], sector_ids: sector_ids,
                 address_attributes: address_attributes)
  end

  def self.create_employer(user, params)
    city = params[:address_attributes] && params[:address_attributes][:city]
    params.delete(:address_attributes) if city.blank? && params[:address_attributes]
    params[:employer_source_id] ||= user.default_employer_source_id
    employer = Employer.new(params)

    if employer.duplicate?
      employer.errors.add(:name, "duplicate employer #{params[:name]}")
      saved = false
    else
      saved = save_employer(employer)
    end

    employer.build_address unless saved || employer.address
    [employer, saved]
  end

  def self.save_employer(employer)
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

  def self.add_employer_file(params, user)
    employer = Employer.find(params[:employer_id])
    saved    = false

    begin
      file = Amazon.store_file(params[:file], 'employer_files')
      employer_file = employer.employer_files.create!(notes: params[:notes],
                                                      file: file, user_id: user.id)
      saved = true
    rescue StandardError => e
      error_message = e.to_s
    end
    [saved, error_message, employer_file]
  end
end
