# frozen_string_literal: true

# This is mainly for applicant grants
# User wants to find near by colleges for each trainee who is not in any class
# and who is NOT placed
# Based on this info they might set up a class in a college that is close to trainees
# a navigator has bunch of counties assigned to them through UserCounty
# a college gets assigned to a navigator based the college county
class NearByCollegesMap < MapService
  NO_COLLEGE_MSG = 'No college within 20 miles'
  attr_reader :navigators, :colleges_no_navigator, :trainees_no_college,
              :fs_id, :error

  def initialize(user, filters)
    return unless init(filters)

    build_navigators(user)
    build_colleges
    build_trainees_no_college
    build_addresses
    attach_trainees_to_colleges
    attach_colleges_to_navigators
    generate_markers_json
  end

  private

  def init(filters)
    @navigators = []
    @trainees_no_college = []
    return false unless filters

    @fs_id = filters[:funding_source_id].to_i
  end

  def grant
    @grant ||= Grant.find(Grant.current_id)
  end

  # builds a hash of navigators
  # key: navigator id
  # value: nav name and colleges
  def build_navigators(user)
    navs = grant.navigators.order(:first, :last)
    navs = ([user] + navs).uniq if user.navigator?
    @navigator_ids = navs.map(&:id)
    os_navs = navs.map do |nav|
      os = OpenStruct.new(name: nav.name, object: nav, colleges: [], trainees_count: 0)
      [nav.id, os]
    end
    @navigators = Hash[os_navs]
  end

  # builds a hash of colleges
  # key: college id
  # value: college name and trainess
  def build_colleges
    os_colleges = College.includes(:address, :open_klasses).order(:name).map do |college|
      os         = build_college_open_struct(college)
      os.klasses = open_klasses(college)
      [college.id, os]
    end
    @colleges = Hash[os_colleges]
  end

  def build_college_open_struct(college)
    OpenStruct.new(name: college.name, id: college.id,
                   county_id: college.county_id,
                   object: college, trainees: [], trainees_count: 0)
  end

  def open_klasses(college)
    college.open_klasses.map do |k|
      "#{k.name}-#{k.start_date} (#{klass_trainee_count(k.id)})"
    end.join('<br/>').html_safe
  end

  # build a collection of trainees where address missing
  # trainees with address but no college near by will be
  # added to this collection in attach_trainees_to_colleges
  def build_trainees_no_college
    no_address_ids =
      trainee_ids - Address.where(addressable_type: 'Trainee').pluck(:addressable_id)
    invalid_address_msg  = 'Trainee address missing or invalid. Check applicant details.'
    @trainees_no_college = Trainee.where(id: no_address_ids)
                                  .order(:first, :last)
                                  .map { |t| [t, nil, invalid_address_msg] }
  end

  def build_addresses
    @addresses = college_addresses + trainee_addresses
  end

  # for each trainee, finds colleges within 15 miles
  # and assigns trainee to nearest college
  def attach_trainees_to_colleges
    a = Address.new
    trainees.each do |t|
      addr = t.home_address
      next unless addr

      trainee     = OpenStruct.new(name: "#{t.name} - #{t.funding_source_name}", id: t.id)
      college_id  = nearest_college(t, a)
      if college_id
        @colleges[college_id].trainees << trainee
      else
        @trainees_no_college << build_no_college_trainee(trainee, addr)
      end
    end
  end

  def nearest_college(t, a)
    addr        = t.home_address
    a.id        = addr.id
    a.latitude  = addr.latitude
    a.longitude = addr.longitude
    c_address   = a.nearbys(20).where(addressable_type: 'College').first
    c_address&.addressable_id
  end

  def build_no_college_trainee(t, addr)
    [t, addr.gmaps4rails_address, NO_COLLEGE_MSG, addr.county]
  end

  def attach_colleges_to_navigators
    @colleges_no_navigator = []
    @colleges.each do |_id, college|
      college.trainees_count = college.trainees.count
      navigator = college_navigator(college)

      @colleges_no_navigator << college unless navigator
      next unless navigator

      navigator.colleges << college
      navigator.trainees_count += college.trainees_count
    end
  end

  def trainee_addresses
    @trainee_addresses ||= HomeAddress.includes(:addressable)
                                      .where(addressable_id: trainee_ids)
  end

  def college_addresses
    @college_addresses ||= Address
                           .includes(:addressable)
                           .where(addressable_type: 'College')
  end

  # all trainees not assigned to a class and not placed
  def trainee_ids
    return @trainee_ids if @trainee_ids

    predicate = { status: 0 }
    predicate[:funding_source_id] = fs_id if fs_id.positive?
    @trainee_ids = Trainee.not_disabled.where(predicate).pluck(:id) -
                   KlassTrainee.pluck(:trainee_id)
  end

  def trainees
    Trainee.includes(:home_address)
           .where(id: trainee_ids)
           .order(:first, :last)
  end

  def college_navigator(college)
    @nav_counties ||= Hash[UserCounty.where(user_id: @navigator_ids)
                                     .pluck(:county_id, :user_id)]
    nav_id          = @nav_counties[college.county_id]
    @navigators[nav_id]
  end

  def klass_trainee_counts
    @ktc ||= Hash[KlassTrainee.group(:klass_id).count]
  end

  def klass_trainee_count(klass_id)
    klass_trainee_counts[klass_id].to_i
  end
end
