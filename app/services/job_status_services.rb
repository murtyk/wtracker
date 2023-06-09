# frozen_string_literal: true

# ask student if they applied for the job shared
class JobStatusServices
  def self.send_job_lead_status_enquiry(shared_job_status)
    UserMailer.enquire_job_lead_status(shared_job_status).deliver_now
  end
end
