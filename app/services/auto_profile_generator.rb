# this is designed specifically for Amazon grant
#   Any grant that has an option auto_profiles_1_week_before_klass
#     any klass ending within a week or sooner
#       klass_titles and klass.college provide jsp
class AutoProfileGenerator
  class << self
    def generate
      Account.all.each do |account|
        Account.current_id = account.id
        account.grants.each do |grant|
          next unless grant.auto_profiles_1_week_before_klass
          Grant.current_id = grant.id
          perform_for_grant(grant)
        end
      end
    end

    private

    def perform_for_grant(grant)
      target_date = Date.today + 7.days
      klasses = grant.klasses.where('end_date <= ?', target_date)
      klasses.each do |klass|
        next unless klass.klass_titles.any?

        log_info("generating profiles for klass: #{klass.name}")
        perform_for_klass(klass)
      end
    end

    def perform_for_klass(klass)
      profile_attrs = build_profie_attributes(klass)

      klass.trainees.each do |trainee|
        next unless trainee.home_address
        add_profile_to_trainee(trainee, profile_attrs)
      end
    end

    def add_profile_to_trainee(trainee, profile_attrs)
      jsp = trainee.job_search_profile

      unless jsp
        create_job_search_profile(trainee, profile_attrs)
        send_login_details(trainee)
        return
      end

      return if jsp.skills.include?(profile_attrs[:skills])

      log_info("updating profile for trainee #{trainee.name}")
      jsp.skills = jsp.skills + ',' + profile_attrs[:skills]
      jsp.save
    end

    def create_job_search_profile(trainee, profile_attrs)
      log_info("creating profile for trainee #{trainee.name}")
      address = trainee.home_address
      attrs = { location: "#{address.city}, #{address.state}", zip: address.zip }
      trainee.create_job_search_profile(profile_attrs.merge(attrs))
    end

    def send_login_details(trainee)
      return unless trainee.grant.
      log_info("sending login details to #{trainee.name}")

      pwd = password(trainee)
      trainee.update(
          login_id: login_id,
          password: pwd,
          password_confirmation: pwd
        )
    end

    def build_profie_attributes(klass)
      {
        skills: klass.klass_titles.map(&:title).join(','),
        distance: 25,
        opted_out: nil,
        opt_out_reason: nil,
        opt_out_reason_code: nil
      }
    end

    def login_id(trainee)
      id    = login_id_name(trainee)
      n = 0
      loop do
        break unless Trainee.unscoped.where(login_id: id).any?
        n += 1
        id += n.to_s
      end
      id
    end

    def login_id_name(trainee)
      first = trainee.first.delete('^a-zA-Z')
      last  = trainee.last.delete('^a-zA-Z')
      first + '_' + last
    end

    def password(trainee)
      (trainee.first[0..2] + '00000000')[0..7]
    end

    def log_info(msg)
      Rails.logger.info("AutoProfileGenerator: #{msg}")
    end
  end
end
