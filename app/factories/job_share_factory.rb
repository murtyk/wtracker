# frozen_string_literal: true

include UtilitiesHelper
# builds and creates job share, shared jobs, job shared tos
# also sends emails
class JobShareFactory
  def self.new_multiple(s_ids, current_user)
    job_ids = s_ids.split(',')
    company = JobSearchServices.company_and_jobs_from_cache(job_ids)
    job_share = JobShare.new(company: company.name, location: company.city_state)

    job_share.job_ids    = job_ids
    job_share.js_company = company
    job_share.from_id    = current_user.id
    job_share.klass_id   = current_user.last_klass_selected

    build_shared_jobs(job_share, company.titles)
    job_share
  end

  def self.create_job_share(job_share_params, job_ids, current_user)
    job_share = build_job_share(job_share_params, job_ids, current_user)

    if job_share.save && job_share.job_shared_tos.any?
      UserMailer.share_jobs(job_share, job_share.sent_to_emails.join(';')).deliver_now
    end
    job_share
  end

  def self.send_to_trainee(params)
    job_share_id = params[:job_share_id]
    trainee_id = params[:trainee_id]
    job_share = JobShare.find(job_share_id)
    trainee = Trainee.find(trainee_id)
    job_share.job_shared_tos.create(trainee_id: trainee.id)
    if Account.track_trainee_status?
      send_jobs_and_track_status(job_share, trainee)
    else
      UserMailer.share_jobs(job_share, trainee.email).deliver_now
    end
  end

  def self.send_jobs_and_track_status(job_share, trainee)
    job_share.shared_jobs.each do |shared_job|
      sjs = shared_job.shared_job_statuses.new(trainee_id: trainee.id,
                                               key: SecureRandom.urlsafe_base64(4))
      sjs.save
      # debugger unless saved
      UserMailer.forward_job_lead(sjs).deliver_now
    end
  end

  def self.build_job_share(job_share_params, job_ids, current_user)
    job_share = new_job_share(job_share_params, job_ids)

    titles = job_titles(job_share_params, job_ids)
    build_shared_jobs(job_share, titles)
    job_share.from_id = current_user.id

    to_ids = trainee_ids(job_share)

    to_ids.each { |tid| job_share.job_shared_tos.new(trainee_id: tid.to_i) }

    job_share
  end

  def self.new_job_share(job_share_params, job_ids)
    if job_ids.blank? # 1 job before analyze

      JobShare.new(job_share_params.slice(:company, :location,
                                          :excerpt, :details_url,
                                          :source, :date_posted))
    else # after analyze
      company = JobSearchServices.company_and_jobs_from_cache(job_ids)
      company_name = company.name
      location = company.poster_location
      JobShare.new(company: company_name,
                   comment: job_share_params[:comment],
                   location: location)
    end
  end

  def self.job_titles(job_share, job_ids)
    # 1 job before analyze
    if job_ids.blank?
      return [[job_share[:title],
               job_share[:details_url],
               job_share[:date_posted]]]
    end
    # 1 or more after analyze
    company = JobSearchServices.company_and_jobs_from_cache(job_ids)
    company.titles
  end

  def self.build_shared_jobs(job_share, titles)
    titles.each do |title_url|
      date_posted = if title_url[2].is_a? String
                      opero_str_to_date(title_url[2])
                    else
                      title_url[2]
                    end
      job_share.shared_jobs.build(title: title_url[0], details_url: title_url[1],
                                  date_posted: date_posted)
    end
  end

  def self.trainee_ids(job_share)
    to_ids = job_share[:to_ids] || []
    to_ids.delete('')
    return to_ids unless to_ids.include?('0')

    klass_id  = job_share[:klass_id]
    klass     = Klass.find(klass_id)
    klass.trainees_for_job_leads.pluck(:trainee_id)
  end
end
